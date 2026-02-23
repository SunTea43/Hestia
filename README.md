# Hestia - Real Estate Management System

Hestia is a premium Ruby on Rails application designed for comprehensive property management. Named after the Greek goddess of the hearth and home, the platform provides a streamlined experience for agents (gestores), property owners, and tenants.

## 🏛️ Project Vision
Hestia aims to digitalize the real estate cycle: from property listing and tenant onboarding to contract management and payment tracking, all within a modern and user-friendly interface.

## 🚀 Key Features
- **Role-Based Access Control**:
  - **Admin**: Full visibility and management across all companies and properties.
  - **Gestor (Real Estate Agent)**: Manage properties, tenants, and contracts for specifically assigned companies.
  - **Inquilino (Tenant)**: Personal portal to view contracts, download documents, and track payments.
- **Property Portfolio**: Comprehensive tracking of properties (for rent or sale) including area, amenities, pricing, and descriptions.
- **Contract Management**: Automated linking of properties and tenants, including co-debtor information and income verification.
- **Financial Tracking**: Management of monthly rent charges and extraordinary fees (cleaning, legal, etc.) with payment status monitoring.
- **Premium UI/UX**: Built with Bootstrap, Lucide Icons, and a custom "Hestia Gold" theme for a professional look and feel.

## 🛠️ Technology Stack
- **Framework**: Ruby on Rails 8.1.2
- **Database**: PostgreSQL
- **Authentication**: Devise
- **Authorization**: Pundit
- **Styling**: Bootstrap with CSS Bundling (Dart Sass)
- **Icons**: Lucide Rails
- **Background Jobs/Cache**: Solid Queue / Solid Cache / Solid Cable

## ⚙️ Getting Started

### Prerequisites
- Ruby 3.2.2+
- PostgreSQL
- Node.js & npm/yarn

### Installation
1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd hestia
    ```
2.  **Install dependencies**:
    ```bash
    bundle install
    npm install
    ```
3.  **Setup Database**:
    ```bash
    rails db:setup
    ```
4.  **Compile Assets**:
    ```bash
    npm run build:css
    ```
5.  **Run the Server**:
    ```bash
    ./bin/dev
    ```

### Demo Credentials (from Seeds)
- **Admin**: `admin@hestia.com` / `password`
- **Gestor**: `gestor@hestia.com` / `password`
- **Tenant**: `inquilino@hestia.com` / `password`

## 🧪 Testing
The project includes System Tests for critical flows. Run them using:
```bash
rails test:system
```

---
Developed with ❤️ by Antigravity for the Hestia Project.
