# Carl Ramses Toussaint — IT Operations Portfolio

**Difficulty: Medium**

A bilingual, responsive portfolio website for the projects in the Windows and Microsoft 365 IT Automation Toolkit. It is a static site: no server, build step, tracking script, or third-party JavaScript library is required.

## Features

- English and French language toggle.
- Light and dark themes, with preferences saved in the browser.
- Responsive mobile navigation with keyboard support.
- Project category filters and live search.
- Direct links to the project source in this repository.
- Five GitHub Actions workflows for PowerShell analysis, compatibility parsing, portfolio checks, Pages deployment, and package artifacts.
- Accessible headings, labels, visible keyboard focus, and reduced-motion support.

## Repository automations

- ../.github/workflows/powershell-analysis.yml — runs PSScriptAnalyzer on changed PowerShell code.
- ../.github/workflows/powershell-compatibility.yml — parses scripts with Windows PowerShell 5.1 and PowerShell 7.
- ../.github/workflows/portfolio-validation.yml — checks JavaScript syntax, local site files, and in-page links.
- ../.github/workflows/deploy-portfolio.yml — publishes this folder to GitHub Pages after a relevant change on main, or from a manual run.
- ../.github/workflows/release-package.yml — builds a source ZIP and SHA-256 checksum as a downloadable Actions artifact when a v* tag is pushed or the workflow is run manually.

## Preview locally

Open index.html in a modern browser. Navigation, theme, language, project filters, search, and repository links work without a build step or network connection.

## Publish with GitHub Pages

Choose Settings → Pages → Build and deployment → Source: GitHub Actions. The deployment workflow publishes this folder when a relevant change is pushed to main and also supports a manual run from the Actions tab.

## Files

- index.html — semantic page content and project links.
- styles.css — responsive layout, color themes, and component styles.
- app.js — language, theme, navigation, and project filtering behavior.
- favicon.svg — small vector site mark.
