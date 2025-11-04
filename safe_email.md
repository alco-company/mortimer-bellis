What your headers say (good news)

SPF: pass (smtp.mailfrom=...@mta.mortimer.pro, IP 212.11.79.135)

DKIM: pass for mortimer.pro (header.i=@mortimer.pro, selector mlsend2) and Mailersend’s domain (double-signing is fine)

DMARC: pass with policy = REJECT applied (header.from=mortimer.pro)

Return-Path / bounce domain: mta.mortimer.pro → aligned with your DMARC setup

TLS: yes

Multipart: you include text/plain and text/html

So authentication + alignment are correct. Step 1 is done ✅.

Why some Gmail recipients could still see spam/promotions

With auth done, remaining causes are reputation + content + headers:

No List-Unsubscribe headers (bulk-sender rule & user experience)
Add both:

List-Unsubscribe: <mailto:unsubscribe@mortimer.pro>, <https://mortimer.pro/unsubscribe?u=<id>>
List-Unsubscribe-Post: List-Unsubscribe=One-Click


Even for “invitations”, providing an easy opt-out lowers complaints and helps inboxing.

Tracking on Mailersend domain
Your CTA link is via click.mailersend.net and there’s an open-pixel from that domain. Brand this with a custom tracking domain (e.g., lnk.mortimer.pro) in Mailersend. It improves domain consistency and trust.

Preheader contains lots of odd/invisible bytes
I can see a long hidden <div class="hidden"> with many strange characters. That can look spammy. Replace preheader with a short, human sentence (e.g., “Accept your Mortimer invitation.”), and keep it clean ASCII/UTF-8 without artifacts.

Literal translation_missing appears
In both text and HTML parts you have:

<span class="translation_missing" title="translation missing: da.devise.mailer.invitation_instructions.someone_invited_you ...">Someone Invited You</span>


That screams “template bug” to filters and users. Fix your i18n so the rendered text is normal Danish, not “translation missing”.

Subject styling
Invitation til at oprette ... på MORTIMER (with spaced caps) can look promotional. Use natural casing:

Invitation: Opret din Mortimer-profil

New domain/reputation & engagement
If this stream is new, warm it up: send smaller volumes to engaged users first, avoid spikes, and watch complaints (<0.3%). Use Gmail Postmaster Tools for domain reputation.

Optional: BIMI & strict policies
You already run p=reject (great). Consider adding BIMI later (requires a VMC) for extra trust in some inboxes.

Quick to-do list (prioritized)

Add List-Unsubscribe + List-Unsubscribe-Post headers.

Enable custom tracking domain (e.g., lnk.mortimer.pro) in Mailersend and use it in all links/pixels.

Fix the i18n so no translation_missing appears; make the Danish copy clean in both HTML and plaintext.

Clean the preheader to a short sentence; remove weird/invisible characters.

Tidy subject (no spaced caps).