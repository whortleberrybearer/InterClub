# Contact Page Design

**Date:** 2026-05-17

## Overview

Add a contact page to the InterClub static site so that runners, clubs, and the general public can send messages to the site owner without exposing their email address. The form is built as plain HTML ready for Netlify Forms integration at a later point — adding Netlify Forms requires only adding `data-netlify="true"` to the form element.

## Pages

### `src/pages/contact.astro`

A contact form page using the existing `Layout.astro` wrapper.

**Form fields:**
- Name (text input, required)
- Email (email input, required)
- Message (textarea, required)

**Form attributes:**
- `method="POST"`
- `action="/contact/thank-you/"`

No JavaScript. Styled with DaisyUI form classes consistent with the rest of the site.

**Netlify integration (future):** Add `data-netlify="true"` to the `<form>` element and configure the notification email in the Netlify dashboard. No other code changes required.

### `src/pages/contact/thank-you.astro`

A simple confirmation page shown after successful form submission.

Content: a short success message ("Thanks for getting in touch — we'll get back to you soon.") and a link back to the home page. Uses `Layout.astro`.

## Navigation

Add a "Contact" link to the navbar in `src/components/Layout.astro`, alongside the existing Road GP and Fell links. Follows the existing active-state pattern using `isActive()`.

## Out of Scope

- Netlify Forms `data-netlify` attribute (added later when deploying to Netlify)
- Spam protection (honeypot / reCAPTCHA — added alongside Netlify integration)
- Subject/topic field
- Club affiliation field
