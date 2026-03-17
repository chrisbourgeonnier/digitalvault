# DigitalVault

A secure, minimalist marketplace for digital downloads (PDFs, templates, etc.) built with Ruby on Rails 8. This project serves as a warmup for a larger project, focusing on rapid development, Rails and security best practices, clean UX, and assistance from AI (Perplexity).

## Live Demo

🌐 [https://digitalvault-mzj6.onrender.com](https://digitalvault-mzj6.onrender.com)

## Project Goals

- **Security First**: Devise authentication, Pundit authorization, rate limiting, encrypted credentials
- **Modern Stack**: Rails 8, Hotwire, Tailwind CSS, PostgreSQL
- **Lean Architecture**: Session-based cart, Stripe payments, secure file delivery
- **Best Practices**: Strong parameters, HTTPS enforcement, security headers, zero Brakeman warnings

## Tech Stack

- **Framework**: Ruby on Rails 8.1.2
- **Ruby**: 3.3.5
- **Database**: PostgreSQL 18
- **Authentication**: Devise 4.9.4 (12 char minimum passwords)
- **Authorization**: Pundit 2.5.2
- **Payments**: Stripe 18.1.0 with webhooks
- **Rate Limiting**: Rack Attack (memory store in production)
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **Styling**: Tailwind CSS v4 (via tailwindcss-rails)
- **File Storage**: Cloudflare R2 via ActiveStorage (aws-sdk-s3 1.x)
- **File Uploads**: ActiveStorage + image_processing 1.14.0
- **Security Scanning**: Brakeman 7.1.2
- **Hosting**: Render (free tier)

## Features Implemented

### ✅ Authentication & Authorization
- User authentication via Devise (email/password, sign up/in/out)
- Strong password requirements (12+ characters)
- Pundit policies for role-based authorization
- Users can only edit/delete their own products
- Users can only view their own orders
- Purchase verification for downloads

### ✅ Products
- Full CRUD for digital products
- Product model: title, description, price, digital file (ActiveStorage)
- Seller dashboard: create, edit, delete own products
- Public catalog: browse all products, view details
- File upload support: PDF, PNG, JPG, JPEG, ZIP, DOC, DOCX
- Product preview images stored persistently on Cloudflare R2

### ✅ Shopping Cart
- Session-based cart (encrypted, no database storage)
- Add/remove products with quantity management
- Real-time cart count badge in navigation
- Line items with subtotals and order total
- Cart persists across page refreshes

### ✅ Stripe Payment Integration
- Stripe Checkout Session for secure payments
- Order model with status tracking (pending/paid/failed/cancelled)
- Cart data stored as JSON with each order
- Webhook handling for payment confirmation
- Automatic order status updates via webhooks
- Success and cancel pages

### ✅ Secure File Delivery
- Download authorization via Pundit DownloadPolicy
- Purchase verification: users can only download files they've paid for
- Secure file delivery through ActiveStorage
- Direct file downloads with proper disposition headers

### ✅ User Dashboard
- Order history page with all user purchases
- Order details view with product information
- Re-download capability for purchased files
- Order status display (pending/paid/failed/cancelled)

### ✅ Persistent File Storage (Cloudflare R2)
- All uploaded files stored on Cloudflare R2 (S3-compatible)
- Files persist across deploys and server restarts
- Signed URLs for secure, time-limited file access
- Server-side AES256 encryption at rest
- Long-term browser caching for images (1 year)
- Credentials stored via Rails encrypted credentials + Render env vars

### ✅ Security Hardening
- **Brakeman**: Zero security vulnerabilities detected
- **Rack Attack**: Rate limiting on login attempts (5 per 20s) and password resets (3 per 5min)
- **Security Headers**: X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, Referrer-Policy, Permissions-Policy
- **HTTPS Enforcement**: Configured for production with force_ssl
- **CSRF Protection**: Rails default protection enabled
- **Strong Parameters**: All controllers use permit patterns

### ✅ Deployment (Render)
- Deployed to Render free tier
- PostgreSQL hosted on Render
- Solid Queue / Cache / Cable migrated safely on each deploy
- Stripe production webhooks configured
- All secrets via Rails encrypted credentials + environment variables

## Setup Instructions

### Prerequisites
- Ruby 3.3.5 (via rbenv)
- PostgreSQL installed and running
- Stripe account (test mode)
- Cloudflare R2 bucket + API credentials
- macOS or Ubuntu/WSL2

### Installation

```bash
# Clone repository
git clone https://github.com/chrisbourgeonnier/digitalvault.git
cd digitalvault

# Install dependencies
bundle install

# Setup database
rails db:create db:migrate

# Setup credentials
EDITOR="code --wait" rails credentials:edit
```

**Add to credentials:**

```yaml
stripe:
  publishable_key: pk_test_YOUR_KEY
  secret_key: sk_test_YOUR_KEY
  webhook_secret: whsec_YOUR_WEBHOOK_SECRET

cloudflare:
  r2_access_key_id: YOUR_R2_ACCESS_KEY
  r2_secret_access_key: YOUR_R2_SECRET_KEY

smtp:
  user_name: YOUR_SMTP_USER
  password: YOUR_SMTP_PASSWORD
```

### Development Workflow

**Two terminals required:**

**Terminal 1 — Rails Server:**
```bash
bin/dev
# Runs Rails server + Tailwind CSS watcher
```

**Terminal 2 — Stripe Webhooks:**
```bash
# Install Stripe CLI first (one time)
# See: https://stripe.com/docs/stripe-cli

stripe login
stripe listen --forward-to localhost:3000/webhooks/stripe
```

**Note:** Copy the `whsec_...` signing secret from Stripe CLI output and add it to credentials.

## Deployment (Render)

### Environment Variables Required on Render

| Key | Value |
|---|---|
| `DATABASE_URL` | Internal Database URL from Render PostgreSQL dashboard |
| `RAILS_MASTER_KEY` | Contents of `config/master.key` (use `cat config/master.key \| tr -d '\n'`) |
| `RAILS_ENV` | `production` |
| `WEB_CONCURRENCY` | `2` |
| `RAILS_MAX_THREADS` | `3` |
| `CLOUDFLARE_R2_ACCESS_KEY_ID` | R2 API access key (fallback if credentials unavailable) |
| `CLOUDFLARE_R2_SECRET_ACCESS_KEY` | R2 API secret key (fallback if credentials unavailable) |

### Build Script

`bin/render-build.sh` handles all deploy steps automatically:
- Bundle install
- Asset precompilation
- Primary database migrations (`db:migrate`)
- Solid Queue / Cache / Cable **migrations** — uses `db:migrate` not `db:schema:load` to avoid wiping data

> ⚠️ Never use `db:schema:load` for Solid Queue/Cache/Cable on Render — it destroys all background job and cache data on every deploy.

### Stripe Webhook (Production)

Configure a webhook endpoint in the Stripe dashboard pointing to:
```
https://digitalvault-mzj6.onrender.com/webhooks/stripe
```
Listen for: `checkout.session.completed`

### Cloudflare R2 Configuration

R2 bucket: `digitalvault-files`

`config/storage.yml` R2 settings:
```yaml
cloudflare_r2:
  service: S3
  region: auto
  force_path_style: true
  request_checksum_calculation: "when_required"
  response_checksum_validation: "when_required"
  upload:
    acl: public-read
    server_side_encryption: "AES256"
    cache_control: "max-age=31557600, public"
```

### ⚠️ Known Limitations (Free Tier)
- **Cold starts**: free tier spins down after inactivity — first request may take 30–60s. Use [UptimeRobot](https://uptimerobot.com) to ping `/up` every 5 minutes to keep the app warm.
- **PostgreSQL expires after 30 days**: recreate or upgrade the Render database before expiry.
- **Image variants**: server-side thumbnail processing (ImageMagick) is incompatible with R2 tempfiles on Render free tier. Images are served at original size and resized via CSS `object-fit`.

## Project Structure

```
app/
├── controllers/
│   ├── products_controller.rb     # CRUD with Pundit authorization
│   ├── carts_controller.rb        # Session-based cart management
│   ├── checkout_controller.rb     # Stripe payment flow
│   ├── orders_controller.rb       # Order history with Pundit scope
│   ├── downloads_controller.rb    # Secure file delivery
│   └── webhooks_controller.rb     # Stripe webhook handling
├── models/
│   ├── user.rb                    # Devise auth, has_many :products, :orders
│   ├── product.rb                 # belongs_to :user, has_one_attached :digital_file + :image
│   └── order.rb                   # belongs_to :user, stores cart_data JSON
├── policies/
│   ├── product_policy.rb          # Authorization: only owners can edit
│   ├── order_policy.rb            # Authorization: users see own orders
│   └── download_policy.rb         # Authorization: purchased files only
├── views/
│   ├── products/                  # Index, show, new, edit
│   ├── carts/                     # Cart view with line items
│   ├── checkout/                  # Success and cancel pages
│   └── orders/                    # Order history and details
└── config/
    ├── storage.yml                # Cloudflare R2 configuration
    ├── database.yml               # Multi-database config (primary/queue/cache/cable)
    └── initializers/
        ├── stripe.rb              # Stripe API configuration
        ├── rack_attack.rb         # Rate limiting rules
        └── security_headers.rb    # HTTP security headers
```

## Security Features

✅ **Zero Brakeman Warnings** — Clean security scan
✅ **Pundit Authorization** — Role-based access control
✅ **Rate Limiting** — Brute force protection via Rack Attack
✅ **HTTPS Enforcement** — Production SSL required
✅ **Security Headers** — XSS, clickjacking, MIME-sniffing protection
✅ **Strong Passwords** — 12+ character requirement
✅ **CSRF Protection** — Rails token verification
✅ **Encrypted Credentials** — Master key for all secrets
✅ **Webhook Signature Verification** — Stripe signature validation
✅ **R2 Encryption at Rest** — AES256 server-side encryption

## Configuration Reference

### Rack Attack
- Global limit: 60 requests/minute per IP
- Login attempts: 5 per 20 seconds per IP and per email
- Password resets: 3 per 5 minutes per IP
- Cache store: MemoryStore in production (avoids Solid Cache dependency at boot)

### Devise
- Minimum password length: 12 characters
- Email confirmation: disabled
- Password reset: enabled

### Stripe
- API keys stored in encrypted credentials
- Webhook endpoint: `/webhooks/stripe`
- Test card: `4242 4242 4242 4242`, any future date, any CVC

## Test Payment Flow

1. Add products to cart
2. Proceed to checkout
3. Use test card: `4242 4242 4242 4242`
4. Complete payment on Stripe-hosted page
5. Verify order status changes to "paid"
6. Download purchased file from order history

## Roadmap

### ✅ Phase 1: Core MVP (Complete)
- Authentication & authorization
- Products CRUD
- Shopping cart
- Stripe payments & webhooks
- Secure downloads
- Order history
- Security hardening

### ✅ Phase 2: Deployment (Complete)
- Render hosting
- Production database
- Stripe production webhooks
- Encrypted credentials

### ✅ Phase 3: Storage (Complete)
- Persistent file storage (Cloudflare R2)
- Safe deploy pipeline

### 🚧 Phase 4: UX Polish (Planned)
- Email receipts
- Product categories

### 🔮 Phase 5: Full Marketplace
- Seller shops & profiles
- Stripe Connect for seller payouts
- Reviews and ratings
- GDPR compliance features
- EU hosting migration

## Troubleshooting

### Webhooks Not Working Locally
- Ensure Stripe CLI is running: `stripe listen --forward-to localhost:3000/webhooks/stripe`
- Check webhook secret in credentials matches CLI output
- Enable caching if needed: `rails dev:cache`

### Rate Limiting in Development
- Check logs for `[Rack::Attack] Throttled` messages
- Wait 20 seconds between login attempts during testing

### File Upload Issues
- Verify ActiveStorage: `rails active_storage:install`
- Check `digital_file` and `image` are in strong parameters
- Test attachment: `product.digital_file.attached?`
- Verify R2 env vars are set on Render dashboard

### Puma Crashing on Render
- Never use `db:schema:load` for queue/cache/cable — use `db:migrate` instead
- Ensure `WEB_CONCURRENCY` and `RAILS_MAX_THREADS` are set in Render env vars
- Check all Solid Queue/Cache tables exist after deploy

### Cold Start / Port Timeout on Render
- Free tier spins down after 15 min inactivity
- Set up UptimeRobot to ping `https://digitalvault-mzj6.onrender.com/up` every 5 minutes
- First request after spin-down takes 30–60 seconds — this is normal

## Credits

Built by **Chris Bourgeonnier** (January–March 2026) with assistance from Perplexity AI, following Rails 8 best practices for rapid, secure MVP development.

## License

TBD
