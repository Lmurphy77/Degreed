import express from "express";
import { ensureSchemaAndSeed, queryOneRandomQuote } from "./db.js";

const app = express();
const port = process.env.PORT || 8080;


app.get("/healthz", (_, res) => res.status(200).send("ok"));


app.get("/", async (req, res) => {
  try {
    const q = await queryOneRandomQuote();
    res.type("html").send(`
      <!doctype html>
      <html lang="en">
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width,initial-scale=1" />
          <title>Famous Quotes</title>
          <style>
            body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; 
                   margin: 0; min-height: 100vh; display: grid; place-items: center; background:#0f172a; color:#e2e8f0; }
            .card { max-width: 720px; padding: 32px 28px; background:#111827; border-radius:16px; box-shadow: 0 8px 30px rgba(0,0,0,.25); }
            blockquote { font-size: 1.5rem; line-height: 1.5; margin: 0 0 12px 0; }
            cite { display:block; opacity:.8; font-style: normal; text-align: right; }
          </style>
        </head>
        <body>
          <div class="card">
            <blockquote>“${q ? escapeHtml(q.Text) : "No quotes yet."}”</blockquote>
            <cite>${q && q.Author ? "— " + escapeHtml(q.Author) : ""}</cite>
          </div>
        </body>
        <script>
          function escapeHtml(s){return s?.replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))}
        </script>
      </html>
    `);
  } catch (err) {
    res.status(500).type("text").send("Error fetching quote");
  }
});

app.listen(port, async () => {
  try {
    await ensureSchemaAndSeed();

    console.log(`Quotes app listening on ${port}`);
  } catch (e) {
    console.error("Startup failed:", e?.message || e);
    process.exit(1);
  }
});


function escapeHtml(s) { return s?.replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c])) }
