# Logo Assets

This directory contains the logo files for the documentation site.

## Required Files

### 1. `redhat-logo-white.png`
- **Purpose**: Displayed in the header/navigation bar
- **Recommended size**: 120x40 pixels (or similar aspect ratio)
- **Format**: PNG with transparent background
- **Color**: White version of Red Hat logo (for red header background)
- **Source**: Download from [Red Hat Brand](https://www.redhat.com/en/about/brand/standards/logo) or contact Red Hat marketing

### 2. `indigo-favicon.png`
- **Purpose**: Browser favicon/tab icon
- **Recommended size**: 32x32 or 64x64 pixels
- **Format**: PNG or ICO
- **Source**: IndiGo Airlines brand assets

### 3. (Optional) `indigo-logo.png`
- **Purpose**: Can be added to footer or homepage
- **Recommended size**: 150x50 pixels
- **Format**: PNG with transparent background
- **Source**: IndiGo Airlines brand assets

## How to Add Logos

1. Obtain official logo files from:
   - Red Hat: https://www.redhat.com/en/about/brand/standards/logo
   - IndiGo Airlines: Contact IndiGo marketing/brand team

2. Place the files in this directory:
   ```
   docs/assets/
   ├── redhat-logo-white.png
   ├── indigo-favicon.png
   └── indigo-logo.png (optional)
   ```

3. The logos are already configured in `mkdocs.yml`:
   - Header logo: `logo: assets/redhat-logo-white.png`
   - Favicon: `favicon: assets/indigo-favicon.png`

## Temporary Placeholder

If you don't have the logos yet, you can use a simple SVG or download public domain versions:

- Red Hat logo (white): Use the official Red Hat brand assets
- IndiGo Airlines: Contact brand team for approved assets

## Brand Guidelines

- Always use official, approved logo versions
- Maintain proper aspect ratios
- Use appropriate color versions (white for dark backgrounds)
- Ensure logos are clear and legible at specified sizes
