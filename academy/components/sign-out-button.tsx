"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
export default function SignOutButton(){const [busy,setBusy]=useState(false);const router=useRouter();async function signOut(){setBusy(true);const supabase=createClient();await supabase.auth.signOut();router.replace("/login");router.refresh();}return <button className="btn secondary" onClick={signOut} disabled={busy}>{busy?"Signing out…":"Sign out"}</button>}