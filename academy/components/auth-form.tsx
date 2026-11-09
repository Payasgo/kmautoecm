"use client";
import { useState } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

type Props = { mode: "login" | "signup" };
export default function AuthForm({ mode }: Props) {
  const [name,setName]=useState(""); const [email,setEmail]=useState(""); const [password,setPassword]=useState("");
  const [busy,setBusy]=useState(false); const [error,setError]=useState(""); const [success,setSuccess]=useState("");
  const router=useRouter(); const params=useSearchParams(); const next=params.get("next")==="/dashboard"?"/dashboard":"/dashboard";
  async function submit(e:React.FormEvent<HTMLFormElement>){e.preventDefault();setBusy(true);setError("");setSuccess("");
    try { const supabase=createClient();
      if(mode==="signup"){const {data,error}=await supabase.auth.signUp({email,password,options:{data:{full_name:name}}});if(error)throw error;
        if(data.session){router.replace("/dashboard");router.refresh();}else setSuccess("Account created. Check your email for the confirmation link, then sign in.");
      } else {const {error}=await supabase.auth.signInWithPassword({email,password});if(error)throw error;router.replace(next);router.refresh();}
    } catch(err){setError(err instanceof Error?err.message:"Something went wrong. Please try again.");} finally{setBusy(false);}
  }
  return <form onSubmit={submit}>
    {mode==="signup"&&<div className="field"><label htmlFor="name">FULL NAME</label><input id="name" autoComplete="name" required minLength={2} value={name} onChange={e=>setName(e.target.value)} placeholder="Your full name"/></div>}
    <div className="field"><label htmlFor="email">EMAIL ADDRESS</label><input id="email" type="email" autoComplete="email" required value={email} onChange={e=>setEmail(e.target.value)} placeholder="you@example.com"/></div>
    <div className="field"><label htmlFor="password">PASSWORD</label><input id="password" type="password" autoComplete={mode==="login"?"current-password":"new-password"} required minLength={8} value={password} onChange={e=>setPassword(e.target.value)} placeholder="At least 8 characters"/></div>
    {error&&<p className="formError" role="alert">{error}</p>}{success&&<p className="formSuccess" role="status">{success}</p>}
    <button className="btn full" disabled={busy}>{busy?"Please wait…":mode==="login"?"Sign in to academy →":"Create student account →"}</button>
    <p className="authFoot">{mode==="login"?"New to KMAutos Academy? ":"Already have an account? "}<Link href={mode==="login"?"/signup":"/login"}>{mode==="login"?"Create an account":"Sign in"}</Link></p>
  </form>;
}