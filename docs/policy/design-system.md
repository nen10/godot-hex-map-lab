
𝟭. 𝗗𝗲𝘀𝗶𝗴𝗻 𝗦𝘆𝘀𝘁𝗲𝗺 (𝗽𝘂𝗹𝗹 𝘀𝗰𝗮𝘁𝘁𝗲𝗿𝗲𝗱 𝗨𝗜 𝗶𝗻𝘁𝗼 𝗮 𝗰𝗼𝗺𝗽𝗼𝗻𝗲𝗻𝘁 𝗹𝗶𝗯𝗿𝗮𝗿𝘆)

Task: abstract the scattered UI components, style tokens, and repeated interactions in this project into one unified Design System, a reusable and maintainable component library. Replace the hand-rolled one-off components with library components, route all new UI through the library with no bypassing, and add a review skill at the end. This is a refactor, so start in a worktree.

For this task, write yourself a new end-to-end /goal: complete the whole plan, not just the next step, until the architecture, implementation, tests, review, and final result meet the standard. Split that goal into independent pieces, spawn as many parallel agents as needed to do it better and faster, and give each agent its own dedicated /goal that includes its expected deliverable, verification, and completion standard.

Dispatch them concurrently, keep tracking progress in the right place, synthesize results as they return, resolve conflicts, continue implementation, run real-time validation after important steps, and finish with review, submission/commit when appropriate, and a final summary. Validation should cover the real end-to-end path, including browser/computer use, clicks, keyboard actions, and any necessary operation. Do not stop after partial progress unless blocked by missing credentials, destructive ambiguity, or conflicting requirements.


𝟮. 𝗔𝗰𝗰𝗲𝘀𝘀𝗶𝗯𝗶𝗹𝗶𝘁𝘆 + 𝗺𝘂𝗹𝘁𝗶-𝗱𝗲𝘃𝗶𝗰𝗲

Task: make sure regular, low-vision, keyboard-only, and different-device users can all reliably complete the core actions. Start the app locally from the current commit, walk the core paths at desktop / tablet / phone viewports, and fix responsive issues (overlap / overflow / truncation / horizontal scroll), contrast, font scaling, keyboard (Tab / Enter / Space / Esc), focus states, and the a11y semantics of images / icon buttons / forms / status. Record the issues, the fixes, and the remaining risks, and add a review skill at the end.

For this task, write yourself a new end-to-end /goal: complete the whole plan, not just the next step, until the architecture, implementation, tests, review, and final result meet the standard. Split that goal into independent pieces, spawn as many parallel agents as needed to do it better and faster, and give each agent its own dedicated /goal that includes its expected deliverable, verification, and completion standard.

Dispatch them concurrently, keep tracking progress in the right place, synthesize results as they return, resolve conflicts, continue implementation, run real-time validation after important steps, and finish with review, submission/commit when appropriate, and a final summary. Validation should cover the real end-to-end path, including browser/computer use, clicks, keyboard actions, and any necessary operation. Do not stop after partial progress unless blocked by missing credentials, destructive ambiguity, or conflicting requirements.


𝟯. 𝗚𝗶𝘃𝗲 𝗶𝘁 𝗮 DESIGN.md 𝗳𝗶𝗿𝘀𝘁

DESIGN.md is a concept from Google Stitch: a plain-text design system that spells out color, type scale, spacing, radius, shadow, and component rules, so the agent reads it before every UI build and the style stops drifting. AGENTS.md is how to build it, DESIGN.md is how it should look.

Don't want to write one? Steal it. Someone scraped 73 real ones (Stripe / Linear / Airbnb / Vercel) into [github.com/VoltAgent/awes…](https://github.com/VoltAgent/awesome-design-md). Drop one in your root and tell the agent to make all UI follow DESIGN.md.


𝟰. 𝗨𝗫 𝗮𝘂𝗱𝗶𝘁 (𝗹𝗲𝘁 𝗶𝘁 𝘀𝗲𝗲 𝘁𝗵𝗲 𝘀𝘁𝗮𝘁𝗲 𝗳𝗶𝗿𝘀𝘁)

Act as a senior UX designer auditing this app's core flows. Walk the real user path end to end.

Find: weak information hierarchy, friction, missing feedback, error-prone steps, empty and error states that were never built.

Rate each by severity and give a concrete fix.


𝟱. 𝗥𝗲𝗯𝘂𝗶𝗹𝗱 𝗼𝗻𝗲 𝗽𝗮𝗴𝗲 𝘄𝗶𝘁𝗵 𝗿𝗲𝗮𝗹 𝘁𝗮𝘀𝘁𝗲

Act as a product designer and rebuild this page to feel like Linear / Stripe.

Pin down the style first: a restrained palette, a clear type scale, enough whitespace, consistent radius and shadow. Then build.

Only touch the visuals, no new features, and walk me through every change.


𝟲. 𝗚𝗲𝘁 𝗲𝘃𝗲𝗿𝘆 𝗶𝗻𝘁𝗲𝗿𝗮𝗰𝘁𝗶𝗼𝗻 𝗮𝗻𝗱 𝘀𝘁𝗮𝘁𝗲 𝗿𝗶𝗴𝗵𝘁

Act as a senior frontend engineer and get every interaction and state right.

Cover: loading skeletons, empty states, error states, hover / focus / disabled, plus transitions and feedback on the key actions.

Make it reusable and accessible, then deliver the component structure and full implementation.


𝟳. 𝗕𝘂𝗶𝗹𝗱 𝗮 𝗹𝗮𝗻𝗱𝗶𝗻𝗴 𝗽𝗮𝗴𝗲 𝘁𝗵𝗮𝘁 𝗰𝗼𝗻𝘃𝗲𝗿𝘁𝘀

Act as a conversion-minded designer and build a landing page.

Nail the one-line value prop and the single action you want from the visitor first. Then lay out: hero, social proof, feature sections, FAQ, CTA.

Clean visuals, clear hierarchy, mobile-first. Deliver a complete, shippable page.


𝟴. 𝗠𝗮𝗸𝗲 𝘁𝗵𝗲 𝗳𝗼𝗿𝗺 𝘂𝘀𝗮𝗯𝗹𝗲

Act as a senior frontend engineer and make this form usable.

Cover: real-time validation, clear inline errors, sensible defaults, keyboard and autofill friendly, submitting and success / failure states, long forms split into steps.

Deliver the full implementation.
