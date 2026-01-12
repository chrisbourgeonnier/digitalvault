# DigitalVault

A secure, minimalist marketplace for digital downloads (PDFs, templates, etc.) built with Ruby on Rails 8. This project serves as a warmup for a larger project, focusing on rapid development, Rails and security best practices, clean UX, and assistance from AI (Perplexity).

## Project Goals

- **Security First**: Devise authentication, Pundit authorization, rate limiting, encrypted credentials
- **Modern Stack**: Rails 8, Hotwire, Tailwind CSS, PostgreSQL
- **Lean Architecture**: Session-based cart, Stripe payments, secure file delivery
- **Best Practices**: Strong parameters, HTTPS enforcement, security headers, zero Brakeman warnings

## Tech Stack

- **Framework**: Ruby on Rails 8.1.1
- **Ruby**: 3.3.5
- **Database**: PostgreSQL
- **Authentication**: Devise 4.9.4 (12 char minimum passwords)
- **Authorization**: Pundit 2.5.2
- **Payments**: Stripe 18.1.0 with webhooks
- **Rate Limiting**: Rack Attack
- **Styling**: Tailwind CSS (via tailwindcss-rails)
- **File Uploads**: ActiveStorage + image_processing 1.14.0
- **Security Scanning**: Brakeman 7.1.2

## Features Implemented

### ✅ Authentication & Authorization (Days 1-2)
- User authentication via Devise (email/password, sign up/in/out)
- Strong password requirements (12+ characters)
- Pundit policies for role-based authorization
- Users can only edit/delete their own products
- Users can only view their own orders
- Purchase verification for downloads

### ✅ Products (Day 2)
- Full CRUD for digital products
- Product model: title, description, price, digital file (ActiveStorage)
- Seller dashboard: create, edit, delete own products
- Public catalog: browse all products, view details
- File upload support: PDF, PNG, JPG, JPEG, ZIP, DOC, DOCX

### ✅ Shopping Cart (Day 3)
- Session-based cart (encrypted, no database storage)
- Add/remove products with quantity management
- Real-time cart count badge in navigation
- Line items with subtotals and order total
- Cart persists across page refreshes

### ✅ Stripe Payment Integration (Days 4-5)
- Stripe Checkout Session for secure payments
- Order model with status tracking (pending/paid/failed/cancelled)
- Cart data stored as JSON with each order
- Webhook handling for payment confirmation
- Automatic order status updates via webhooks
- Success and cancel pages

### ✅ Secure File Delivery (Day 6)
- Download authorization via Pundit DownloadPolicy
- Purchase verification: users can only download files they've paid for
- Secure file delivery through ActiveStorage
- Direct file downloads with proper disposition headers

### ✅ User Dashboard (Day 6)
- Order history page with all user purchases
- Order details view with product information
- Re-download capability for purchased files
- Order status display (pending/paid/failed/cancelled)

### ✅ Security Hardening (Day 7)
- **Brakeman**: Zero security vulnerabilities detected
- **Rack Attack**: Rate limiting on login attempts (5 per 20s) and password resets (3 per 5min)
- **Security Headers**: X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, Referrer-Policy, Permissions-Policy
- **HTTPS Enforcement**: Configured for production with force_ssl
- **CSRF Protection**: Rails default protection enabled
- **Strong Parameters**: All controllers use permit patterns

## Setup Instructions

### Prerequisites
- Ruby 3.3.5 (via rbenv)
- PostgreSQL installed and running
- Node.js & Yarn (for asset pipeline)
- Stripe account (test mode)
- Ubuntu/WSL2 or macOS

### Installation

```bash
# Clone repository
git clone <your-repo>
cd digitalvault

# Install dependencies
bundle install

# Setup database
rails db:create db:migrate db:seed

# Setup Stripe credentials
EDITOR="code --wait" rails credentials:edit

**Add to credentials:**

```yaml
stripe:
  publishable_key: pk_test_YOUR_KEY
  secret_key: sk_test_YOUR_KEY
  webhook_secret: whsec_YOUR_WEBHOOK_SECRET
```


### Development Workflow

**Two terminals required:**

**Terminal 1 - Rails Server:**

```bash
bin/dev
# Runs Rails server + Tailwind CSS watcher
```

**Terminal 2 - Stripe Webhooks:**

```bash
# Install Stripe CLI first (one time)
# See: https://stripe.com/docs/stripe-cli

stripe login
stripe listen --forward-to localhost:3000/webhooks/stripe
```

**Note:** Copy the webhook signing secret (`whsec_...`) from Stripe CLI output and add it to your credentials.

### Create Test Data

```bash
rails console

# Create test user with strong password
user = User.create!(email: "seller@example.com", password: "testpassword123")

# Create test product (attach file manually via UI)
user.products.create!(
  title: "Sample Digital Product",
  description: "A test product for development",
  price: 19.99
)

exit
```

Visit `http://localhost:3000`, sign in, and browse products!

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
│   ├── product.rb                 # belongs_to :user, has_one_attached :digital_file
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
    └── initializers/
        ├── stripe.rb              # Stripe API configuration
        ├── rack_attack.rb         # Rate limiting rules
        └── security_headers.rb    # HTTP security headers
```


## Configuration

### Database

PostgreSQL database configured in `config/database.yml` (development: `digitalvault_development`)

### Stripe

- API keys stored in encrypted credentials
- Webhook endpoint: `/webhooks/stripe`
- Test card: `4242 4242 4242 4242`


### Devise

- Minimum password length: 12 characters
- Email confirmation: disabled (development)
- Password reset: enabled


### Rack Attack

- Global limit: 60 requests/minute per IP
- Login attempts: 5 per 20 seconds per IP
- Login attempts: 5 per 20 seconds per email
- Password resets: 3 per 5 minutes per IP


### Tailwind CSS

- Config: `tailwind.config.js`
- Styles: `app/assets/stylesheets/application.tailwind.css`
- Auto-watch via `bin/dev`


## Security Features

✅ **Zero Brakeman Warnings** - Clean security scan
✅ **Pundit Authorization** - Role-based access control
✅ **Rate Limiting** - Brute force protection
✅ **HTTPS Enforcement** - Production SSL required
✅ **Security Headers** - XSS, clickjacking, MIME-sniffing protection
✅ **Strong Passwords** - 12+ character requirement
✅ **CSRF Protection** - Rails token verification
✅ **Encrypted Credentials** - Master key for secrets
✅ **Webhook Signature Verification** - Stripe signature validation

## Development

### Security Scanning

```bash
# Run Brakeman security scan
brakeman

# Expected: 0 warnings
```


### Test Payment Flow

1. Add products to cart
2. Proceed to checkout
3. Use test card: `4242 4242 4242 4242`
4. Complete payment
5. Verify order status changes to "paid" (check logs for webhook)
6. Download purchased file from order history

### Git Workflow

```bash
git add .
git commit -m "Feature: Description"
git push origin main
```


## Roadmap

### ✅ Phase 1: Core MVP (Complete)

- Authentication \& authorization
- Products CRUD
- Shopping cart
- Stripe payments
- Webhooks
- Secure downloads
- Order history
- Security hardening


### 🚧 Phase 2: UX Polish (In Progress)

- Product thumbnails/previews
- Search functionality
- Pagination
- Email receipts
- Product categories


### 📋 Phase 3: Deployment

- Production environment setup
- Database configuration
- Deploy to Render/Hetzner EU VPS
- Production webhook configuration
- Monitoring and logging


### 🔮 Phase 4: Future Enhancements

- Seller shops \& profiles
- Stripe Connect for seller payouts
- Reviews and ratings
- Advanced search
- Physical products support
- GDPR compliance features


## Troubleshooting

### Webhooks Not Working

- Ensure Stripe CLI is running: `stripe listen --forward-to localhost:3000/webhooks/stripe`
- Check webhook secret in credentials matches Stripe CLI output
- Verify logs show `[^200] POST http://localhost:3000/webhooks/stripe`


### Rate Limiting in Development

- Enable caching: `rails dev:cache`
- Check logs for `[Rack::Attack] Throttled` messages
- Wait 20 seconds between login attempts


### File Upload Issues

- Verify ActiveStorage is configured: `rails active_storage:install`
- Check `digital_file` is in strong parameters
- Ensure file is attached: `product.digital_file.attached?`


## Credits

Built by **Chris Bourgeonnier** (January 2026) with assistance from Perplexity AI, following Rails 8 best practices for rapid, secure MVP development.

## License

TBD

```
