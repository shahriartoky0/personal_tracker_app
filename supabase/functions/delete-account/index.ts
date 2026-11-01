// Deletes the calling user. The service-role key never leaves the server.
// Deploy: supabase functions deploy delete-account
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return new Response("Unauthorized", { status: 401, headers: cors });

  const url = Deno.env.get("SUPABASE_URL")!;
  // Identify the caller from THEIR jwt (never trust a body-supplied id).
  const userClient = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data, error } = await userClient.auth.getUser();
  if (error || !data.user) return new Response("Unauthorized", { status: 401, headers: cors });
  const uid = data.user.id;

  const admin = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

  // Remove proof objects under <uid>/ (best effort), then the user (rows cascade).
  try {
    const { data: files } = await admin.storage.from("receipts").list(uid, { limit: 1000 });
    if (files && files.length) {
      await admin.storage.from("receipts").remove(files.map((f) => `${uid}/${f.name}`));
    }
  } catch (_) { /* continue */ }

  const { error: delErr } = await admin.auth.admin.deleteUser(uid);
  if (delErr) return new Response(delErr.message, { status: 500, headers: cors });
  return new Response(JSON.stringify({ ok: true }), {
    headers: { ...cors, "Content-Type": "application/json" },
  });
});
