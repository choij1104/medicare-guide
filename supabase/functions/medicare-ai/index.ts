// medicare-ai — server side of the translate / ask tools in index.html.
// The API key lives only in the Supabase secret ANTHROPIC_API_KEY.
// The page sends a mode, the reply language, the user's text/photos and the
// app's FACTS block; the instructions below are fixed here so the endpoint
// cannot be used as a general-purpose chatbot.

const MODEL = "claude-sonnet-5-5";
const ALLOWED_ORIGINS = [
  "https://choij1104.github.io",
  "http://localhost:8000",
  "http://127.0.0.1:8000",
];
const MAX_TEXT = 20000;
const MAX_FACTS = 12000;
const MAX_IMAGES = 4;
const MAX_IMAGE_B64 = 5_000_000;
const PER_IP_PER_HOUR = 30;

const hits = new Map<string, number[]>();
function limited(ip: string): boolean {
  const now = Date.now();
  const recent = (hits.get(ip) || []).filter((t) => now - t < 3_600_000);
  recent.push(now);
  hits.set(ip, recent);
  return recent.length > PER_IP_PER_HOUR;
}

function cors(origin: string | null): Record<string, string> {
  const allow = origin && ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0];
  return {
    "Access-Control-Allow-Origin": allow,
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "content-type, authorization, apikey, x-client-info",
    "Vary": "Origin",
  };
}

function reply(body: unknown, status: number, origin: string | null) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors(origin), "Content-Type": "application/json" },
  });
}

function instructions(mode: string, lang: string, facts: string): string {
  const target = lang === "en"
    ? "plain simple English"
    : "Korean (polite 존댓말, simple words a Korean senior understands)";
  const base =
    "You help Korean-American seniors in Texas understand Medicare. Answer in " + target +
    ". Do not sell or recommend any specific insurance company. If an ID number (Medicare, SSN, bank) appears, do not repeat it. " +
    "Only handle Medicare, Medicaid, Social Security or health-insurance paperwork and questions; for anything else, say briefly that this tool only helps with Medicare. " +
    "Not legal or financial advice.\n\nFACTS:\n" + facts;
  if (mode === "translate") {
    return base +
      "\n\nThe user sends a document as text and/or photos. Reply with these short sections:\n" +
      "1. What this is (who sent it, what kind of letter)\n2. Translation of the important parts\n" +
      "3. What I need to do, and the deadline (or \"No action needed\")\n4. Scam warning signs (or \"None seen\")\n" +
      "5. Who to call if unsure (use the phones in FACTS)\nPlain text, no tables, no markdown.";
  }
  return base +
    "\n\nAnswer the user's question in under 250 words. Use only the FACTS for numbers and rules; if the answer depends on details not given (their drugs, doctors, income), say what to check and point to the Medicare.gov Plan Finder or Texas HICAP 1-800-252-9240. Plain text, no markdown.";
}

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors(origin) });
  if (req.method !== "POST") return reply({ code: "bad_request" }, 405, origin);
  if (origin && !ALLOWED_ORIGINS.includes(origin)) return reply({ code: "forbidden" }, 403, origin);

  const key = Deno.env.get("ANTHROPIC_API_KEY");
  if (!key) return reply({ code: "not_configured" }, 503, origin);

  const ip = (req.headers.get("x-forwarded-for") || "").split(",")[0].trim() || "unknown";
  if (limited(ip)) return reply({ code: "rate_limited" }, 429, origin);

  let body: any;
  try { body = await req.json(); } catch { return reply({ code: "bad_request" }, 400, origin); }

  const mode = body.mode === "translate" ? "translate" : "qa";
  const lang = body.lang === "en" ? "en" : "ko";
  const text = String(body.text || "");
  const facts = String(body.facts || "").slice(0, MAX_FACTS);
  const images: { type: string; data: string }[] = Array.isArray(body.images) ? body.images : [];

  if (text.length > MAX_TEXT) return reply({ code: "prompt_too_large" }, 413, origin);
  if (images.length > MAX_IMAGES || images.some((i) => !i || typeof i.data !== "string" || i.data.length > MAX_IMAGE_B64)) {
    return reply({ code: "prompt_too_large" }, 413, origin);
  }
  if (!text.trim() && !images.length) return reply({ code: "bad_request" }, 400, origin);

  const content: unknown[] = images.map((i) => ({
    type: "image",
    source: { type: "base64", media_type: /^image\/(jpeg|png|webp|gif)$/.test(i.type) ? i.type : "image/jpeg", data: i.data },
  }));
  content.push({
    type: "text",
    text: mode === "translate"
      ? (text.trim() ? "DOCUMENT TEXT:\n" + text : "The document is in the attached photo(s).")
      : "QUESTION:\n" + text,
  });

  let r: Response;
  try {
    r = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: { "x-api-key": key, "anthropic-version": "2023-06-01", "content-type": "application/json" },
      body: JSON.stringify({
        model: MODEL,
        max_tokens: mode === "translate" ? 2000 : 900,
        system: instructions(mode, lang, facts),
        messages: [{ role: "user", content }],
      }),
    });
  } catch {
    return reply({ code: "upstream" }, 502, origin);
  }

  const data: any = await r.json().catch(() => ({}));
  if (!r.ok) {
    const msg = String(data?.error?.message || "");
    if (r.status === 429) return reply({ code: "rate_limited" }, 429, origin);
    if (/image/i.test(msg)) return reply({ code: "image_rejected" }, 400, origin);
    if (/too long|too large|prompt is too long/i.test(msg)) return reply({ code: "prompt_too_large" }, 413, origin);
    console.error("anthropic error", r.status, msg);
    return reply({ code: "upstream" }, 502, origin);
  }

  const out = (data.content || []).filter((c: any) => c.type === "text").map((c: any) => c.text).join("");
  if (data.stop_reason === "refusal") return reply({ code: "refused" }, 200, origin);
  return reply({ text: out, truncated: data.stop_reason === "max_tokens" }, 200, origin);
});
