# DigitalVault

A secure, minimalist marketplace for digital downloads (PDFs, templates, etc.) built with Ruby on Rails 8. This project serves as a warmup for a larger project, focusing on rapid development, security best practices, clean UX, and assistance from AI (Perplexity).

## Project Goals

- **MVP Focus**: Build a functional digital downloads marketplace
- **Security First**: Devise auth, Pundit authorization, encrypted sessions, GDPR-ready
- **Modern Stack**: Rails 8, Hotwire (no React), Tailwind CSS, PostgreSQL
- **Lean Architecture**: Session-based cart, Stripe payments, minimal dependencies

## Tech Stack

- **Framework**: Ruby on Rails 8.1.1
- **Ruby**: 3.3.5
- **Database**: PostgreSQL
- **Authentication**: Devise 4.9.4
- **Authorization**: Pundit 2.5.2 (planned)
- **Payments**: Stripe 18.1.0
- **Styling**: Tailwind CSS 2.1+ (via tailwindcss-rails)
- **Asset Pipeline**: Propshaft
- **File Uploads**: ActiveStorage + image_processing 1.14.0

## Features Built (Days 1-3)

### Step 1: Authentication & Setup
- Rails 8 app with PostgreSQL
- User authentication via Devise (email/password, sign up/in/out)
- Pundit installed for future authorization policies
- Base Tailwind CSS setup with custom styles

### Step 2: Products CRUD
- Product model (title, description, price, file reference, belongs to User)
- Seller dashboard: create, edit, delete own products
- Buyer catalog: browse/search products, view details
- Authorization: only sellers can manage their products

### Step 3: Session-Based Cart
- Add/remove products to cart (stored in encrypted session)
- Cart view with line items, quantities, subtotals, total
- Nav bar with cart count badge
- Quick "Add to Cart" from product listing and detail pages

## Setup Instructions

### Prerequisites
- Ruby 3.3.5 (via rbenv/rvm)
- PostgreSQL installed and running
- Node.js & Yarn (for asset pipeline)
- Ubuntu/WSL2 or macOS

### Installation
```bash
# Clone repo
git clone <your-repo>
cd digitalvault

# Install dependencies
bundle install

# Setup database
rails db:create db:migrate

# Start development server with Tailwind watcher
bin/dev
# Or separately: rails s (port 3000) + bin/rails tailwindcss:watch
```


### Create Test Data

```bash
rails console
user = User.create!(email: 'test@example.com', password: 'password123')
user.products.create!(title: 'Sample PDF', description: 'Test product', price: 9.99, file: 'sample.pdf')
exit
```

Visit http://localhost:3000, sign in, browse /products.

## Project Structure

```
app/
├── controllers/
│   ├── products_controller.rb   # CRUD for products
│   └── carts_controller.rb      # Session cart management
├── models/
│   ├── user.rb                  # Devise auth, has_many :products
│   └── product.rb               # belongs_to :user, validations
├── views/
│   ├── products/                # Index, show, new, edit forms
│   ├── carts/                   # Cart show view
│   └── layouts/
│       └── application.html.erb # Nav bar, flash messages
└── assets/stylesheets/
    └── application.tailwind.css # Tailwind + custom component styles
```


## Configuration

### Database

Edit `config/database.yml` for local PostgreSQL credentials (development env uses `digitalvault_development`).

### Devise

- Mailer configured for localhost:3000 (development)
- User model: email + password (reset available)


### Tailwind CSS

- Config: `tailwind.config.js`
- Stylesheet: `app/assets/stylesheets/application.tailwind.css`
- Build: `bin/rails tailwindcss:build` or auto-watch via `bin/dev`


## Roadmap

### Step 4 (Next): Stripe Checkout

- Stripe API keys setup
- Create checkout session from cart
- Order model for purchase history
- Secure download links post-payment


### Step 5: Security \& Deploy

- Pundit policies (seller/buyer roles)
- Brakeman security scans
- HTTPS enforcement, rate limiting
- Deploy to Render/Hetzner EU VPS


### Future (Phase 2-3)

- Seller shops \& multi-product inventory
- Stripe Connect for seller payouts
- Reviews, search ranking, GDPR flows
- Physical products support


## Development

### Running Tests

TBD


### Code Quality

- RuboCop (Rails Omakase rules): `bundle exec rubocop`
- Brakeman security: `bundle exec brakeman`


### Git Workflow

```bash
git add .
git commit -m "Day X: Feature description"
git push origin main
```


## Credits

Built by Chris Bourgeonnier (January 2026) following Rails 8 best practices for rapid MVP development.

## License

TBD
