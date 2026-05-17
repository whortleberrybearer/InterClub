# Contact Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a contact form page and thank-you page to the InterClub static site, with a nav link, ready for future Netlify Forms integration.

**Architecture:** Two new Astro pages using the existing `Layout.astro` wrapper. The form posts to the thank-you page URL — no JavaScript or backend required. The nav link is added to `Layout.astro` alongside the existing Road GP and Fell links.

**Tech Stack:** Astro v6, Tailwind CSS v4, DaisyUI v5

---

### Task 1: Create the thank-you page

**Files:**
- Create: `src/pages/contact/thank-you.astro`

- [ ] **Step 1: Create the file**

```astro
---
import Layout from '../../components/Layout.astro';
import { siteUrl } from '../../lib/url';
---

<Layout title="Message Sent">
  <div class="max-w-lg mx-auto text-center py-16">
    <h1 class="text-2xl font-bold mb-4">Thanks for getting in touch</h1>
    <p class="text-base-content/70 mb-8">We'll get back to you soon.</p>
    <a href={siteUrl('/')} class="btn btn-primary">Back to home</a>
  </div>
</Layout>
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/contact/thank-you.astro
git commit -m "feat: add contact thank-you page"
```

---

### Task 2: Create the contact form page

**Files:**
- Create: `src/pages/contact.astro`

- [ ] **Step 1: Create the file**

```astro
---
import Layout from '../components/Layout.astro';
import { siteUrl } from '../lib/url';
---

<Layout title="Contact">
  <div class="max-w-lg mx-auto">
    <h1 class="text-2xl font-bold mb-2">Contact</h1>
    <p class="text-base-content/70 mb-8">
      Use this form to report result corrections or send a general enquiry.
    </p>

    <form method="POST" action={siteUrl('/contact/thank-you/')}>
      <div class="form-control mb-4">
        <label class="label" for="name">
          <span class="label-text">Name</span>
        </label>
        <input
          id="name"
          type="text"
          name="name"
          required
          class="input input-bordered w-full"
        />
      </div>

      <div class="form-control mb-4">
        <label class="label" for="email">
          <span class="label-text">Email</span>
        </label>
        <input
          id="email"
          type="email"
          name="email"
          required
          class="input input-bordered w-full"
        />
      </div>

      <div class="form-control mb-6">
        <label class="label" for="message">
          <span class="label-text">Message</span>
        </label>
        <textarea
          id="message"
          name="message"
          required
          rows="6"
          class="textarea textarea-bordered w-full"
        ></textarea>
      </div>

      <button type="submit" class="btn btn-primary w-full">Send message</button>
    </form>
  </div>
</Layout>
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/contact.astro
git commit -m "feat: add contact form page"
```

---

### Task 3: Add Contact link to the navbar

**Files:**
- Modify: `src/components/Layout.astro`

- [ ] **Step 1: Add the Contact nav link**

In `src/components/Layout.astro`, the `navbar-end` div currently contains two links (Road GP, Fell). Add a third link after them:

Find this block (lines ~33–40):
```astro
        <div class="navbar-end gap-1">
          <a
            href={`${base}/road-gp/`}
            class={`btn btn-ghost btn-sm ${isActive('/road-gp') ? 'btn-active' : ''}`}
          >Road GP</a>
          <a
            href={`${base}/fell/`}
            class={`btn btn-ghost btn-sm ${isActive('/fell') ? 'btn-active' : ''}`}
          >Fell</a>
        </div>
```

Replace with:
```astro
        <div class="navbar-end gap-1">
          <a
            href={`${base}/road-gp/`}
            class={`btn btn-ghost btn-sm ${isActive('/road-gp') ? 'btn-active' : ''}`}
          >Road GP</a>
          <a
            href={`${base}/fell/`}
            class={`btn btn-ghost btn-sm ${isActive('/fell') ? 'btn-active' : ''}`}
          >Fell</a>
          <a
            href={`${base}/contact/`}
            class={`btn btn-ghost btn-sm ${isActive('/contact') ? 'btn-active' : ''}`}
          >Contact</a>
        </div>
```

- [ ] **Step 2: Commit**

```bash
git add src/components/Layout.astro
git commit -m "feat: add Contact link to navbar"
```

---

### Task 4: Build and verify

- [ ] **Step 1: Run the build**

```bash
npm run build
```

Expected: build completes with no errors. Look for these output pages in `dist/`:
- `dist/contact/index.html`
- `dist/contact/thank-you/index.html`

- [ ] **Step 2: Smoke-check the output**

Open `dist/contact/index.html` in a text editor and verify:
- The form has `method="POST"` and `action` pointing to `/contact/thank-you/` (with any base URL prefix)
- The three fields (name, email, message) are present with `required` attributes
- The navbar contains a "Contact" link

Open `dist/contact/thank-you/index.html` and verify:
- The success message is present
- There is a link back to the home page

- [ ] **Step 3: Commit is already done per task — no additional commit needed**
