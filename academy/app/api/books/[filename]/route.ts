import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

const allowed = new Set(["Car_Mechanics.pdf","CARTUNING.pdf","ECU_PCB_REPAIR_PRACTICAL_LAB.pdf"]);
export async function GET(_request: Request, {params}:{params:Promise<{filename:string}>}) {
 const {filename}=await params;
 if(!allowed.has(filename)) return new NextResponse("Not found",{status:404});
 const supabase=await createClient();
 const {data:{user}}=await supabase.auth.getUser();
 if(!user) return NextResponse.redirect(new URL("/login","https://learn.kmautoecm.com"));
 const {data}=supabase.storage.from("academy-books").getPublicUrl(filename);
 return NextResponse.redirect(data.publicUrl);
}
