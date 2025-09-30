# Modern Software Development Practices Documentation

This repository contains comprehensive documentation for modern software development practices targeting **junior and mid-senior developers** working with **.NET and React Native applications**. All examples and practices use **Podman/podman compose** and **Red Hat UBI (Universal Base Images)**.

## 🚀 Quick Start

### Prerequisites

- Python 3.7+ installed
- pip package manager
- Git

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd enablement/agile
   ```

2. **Install MkDocs and dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Serve the documentation locally:**
   ```bash
   mkdocs serve
   ```

4. **Open your browser to:**
   ```
   http://localhost:8000
   ```

### Material Theme (preconfigured)

This site is already configured to use the Material theme with helpful UX features. See `agile/mkdocs.yml`:

```yaml
theme:
  name: material
  palette:
    primary: red
    accent: red
  features:
    - navigation.tabs
    - navigation.sections
    - toc.integrate
    - navigation.top
    - search.suggest
    - search.highlight
    - content.tabs.link
    - content.code.annotation
    - content.code.copy
```

## 📚 Documentation Structure

This guide is organized to match the current navigation in `agile/mkdocs.yml`:

### 1. Cloud Fundamentals (`docs/1_cloud/`)
- **Hybrid Cloud** - Hybrid cloud concepts and strategies
- **Cloud Native Development** - Cloud-native development principles
- **CNCF Landscape** - Cloud Native Computing Foundation overview

### 2. Containerization (`docs/2_containerization/`)
- **Container Fundamentals** - Container basics with Podman
- **CRI-O Container Engine** - CRI-O concepts and usage
- **Kubernetes & OpenShift** - Container orchestration

### 3. Development Foundations (`docs/3_foundations/`)
- **Requirement-Centric Development** - Requirements-driven approach
- **12-Factor App Methodology** - Modern app architecture principles
- **Microservices Architecture** - Service-oriented design
- **Clean Architecture** - Architectural design principles
- **Inner Loop Practices** - Developer workflow optimization
- **Non-Functional Requirements** - Performance, security, scalability

### 4. Agile Development & Testing (`docs/4_agiledevtesting/`)
- **BDD and TDD Practices** - Test-driven development approaches
- **Local Development with podman compose** - Development environment setup
- **API Mocking Strategies** - Testing with mock services
- **Performance Testing in Containers** - Container-based performance testing
- **Requirement-Centric Development** - Requirements-driven approach

### 5. Red Hat Ecosystem (`docs/redhat_ecosystem/`)
- **Red Hat Software Collections** - Enterprise development tools

## 🎯 Target Audience

- **Junior developers** (0-3 years experience) learning modern development practices
- **Mid-senior developers** (3-7 years experience) adopting cloud-native and agile methodologies
- **Primary technologies**: .NET (C#) and React Native
- **Containerization**: Podman and podman compose exclusively
- **Base images**: Red Hat UBI images only

## 🛠️ Building and Deployment

### Local Development

```bash
# Start development server with auto-reload
mkdocs serve

# Build static site
mkdocs build

# Deploy to GitHub Pages (if configured)
mkdocs gh-deploy
```

### Container-based Development

Using Podman with the provided `compose.yml`:

```bash
# From the repository root
cd agile

# Start the dev server in a container (auto-installs mkdocs + plugins)
podman compose up

# Or explicitly specify the file
podman compose -f compose.yml up

# Visit http://localhost:8000
```

The service runs using `registry.access.redhat.com/ubi8/python-39`, installs `mkdocs`, `mkdocs-material`, `pymdown-extensions`, plus extras used in the container (`mkdocs-with-pdf`, `mkdocs-mermaid2-plugin`).

To stop:

```bash
podman compose down
```

If you prefer not to use compose, you can run a one-off container:

```bash
podman run --rm -it -p 8000:8000 -v $(pwd)/agile:/app:Z -w /app \
  registry.access.redhat.com/ubi8/python-39 \
  sh -c "pip install mkdocs mkdocs-material pymdown-extensions && mkdocs serve -a 0.0.0.0:8000"
```

Note: SELinux systems may require the `:Z` volume flag as shown above.

### GitHub Pages Deployment

There are two supported options: on-demand deploy from your machine, or automatic deploy with GitHub Actions.

1) Manual deploy using `gh-pages` branch (simple):

```bash
# Ensure your repo has a remote named 'origin'
git remote -v

# Optional but recommended in agile/mkdocs.yml
# site_url: https://<your-user-or-org>.github.io/<your-repo>

# Build and publish to the gh-pages branch
cd agile
mkdocs gh-deploy --clean

# If your default remote is not 'origin'
mkdocs gh-deploy --clean --remote-name origin
```

After the first deploy, enable GitHub Pages:
- In your repository, go to Settings → Pages
- Set Source to "Deploy from a branch" and choose `gh-pages` (root)

2) Automatic deploy with GitHub Actions (recommended):

Add this workflow at `.github/workflows/deploy-docs.yml` in your repository root:

```yaml
name: Deploy MkDocs to GitHub Pages
on:
  push:
    branches: [ main ]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.x'
      - name: Install deps
        run: pip install -r agile/requirements.txt
      - name: Build site
        run: mkdocs build -f agile/mkdocs.yml
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: agile/site
  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

Then:
- Go to Settings → Pages → Build and deployment → Source: select "GitHub Actions".
- Push to `main`. The workflow builds the site from `agile/` and publishes it to Pages.

Custom domain: create a `CNAME` file via Pages settings; MkDocs will include it on deploy.

## 🔧 Configuration

### MkDocs Configuration

The `agile/mkdocs.yml` file contains the complete site configuration:

- **Site metadata**: Title and description
- **Theme configuration**: Material theme and UX features
- **Navigation structure**: Mirrors the sections above
- **Plugins**: `search`
- **Markdown extensions**: `admonition`, `codehilite` (with Pygments), `toc`, `tables`, `fenced_code`, `pymdownx.details`, `pymdownx.superfences`

### Environment Variables

For customization, you can use these environment variables:

```bash
export SITE_NAME="Your Custom Site Name"
export SITE_URL="https://your-domain.com"
export REPO_URL="https://github.com/your-org/your-repo"
```

## 📋 Contributing

### Content Guidelines

When contributing to this documentation:

1. **Follow the template structure** defined in `.github/instructions.md`
2. **Use Podman exclusively** - no Docker examples
3. **Use Red Hat UBI images** for all containerization examples
4. **Target junior/mid-senior developers** with appropriate explanations
5. **Include practical examples** with .NET and React Native
6. **Test all code examples** before submitting
7. **Follow markdown best practices** for readability

### Adding New Content

1. Create new markdown files in the appropriate section directory
2. Update `mkdocs.yml` navigation to include new pages
3. Follow the standard document structure:
   - Overview
   - Key Concepts
   - Prerequisites
   - Practical Examples
   - Common Pitfalls
   - Best Practices
   - Tools and Resources
   - Hands-on Exercise
   - Summary

### Code Style

- **Use consistent indentation** (2 spaces for YAML, 4 for code blocks)
- **Include working examples** that can be copy-pasted
- **Add comments** to explain complex concepts
- **Use proper syntax highlighting** with language identifiers

## 🔍 Troubleshooting

### Common Issues

**MkDocs serve fails:**
```bash
# Check Python version
python --version

# Reinstall dependencies
pip install --upgrade -r requirements.txt

# Clear previous local build output
rm -rf agile/site/
```

**Theme not found:**
```bash
# Ensure Material theme is installed (already in requirements.txt)
pip install -r agile/requirements.txt
```

**Port already in use:**
```bash
# Use different port
mkdocs serve --dev-addr localhost:8001

# Or kill existing process
lsof -ti:8000 | xargs kill -9
```

## 📞 Support

For questions about:

- **Documentation content**: Create an issue with content questions
- **Technical setup**: Check troubleshooting section or create an issue
- **Contributing**: Review the contributing guidelines above

## 📄 License

This documentation is provided under the MIT License. See LICENSE file for details.

---

*Last updated: $(date)*
*Documentation version: 1.0.0*

