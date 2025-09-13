# PGN Parser Documentation

This directory contains documentation for the PGN Parser project, which is deployed to GitHub Pages.

## Local Development

### Requirements

- Ruby 2.7 or higher
- Bundler
- Jekyll 4.0 or higher

### Installation

```bash
# Install Bundler
gem install bundler

# Install dependencies
bundle install

# Start local server
bundle exec jekyll serve

# Open in browser
open http://localhost:4000/pgn_parser/
```

### Commands

```bash
# Build site
bundle exec jekyll build

# Build with incremental changes
bundle exec jekyll build --incremental

# Run in development mode
bundle exec jekyll serve --livereload

# Clean and rebuild
bundle exec jekyll clean && bundle exec jekyll build
```

## Page Structure

### Home Page (`index.md`)

Contains:
- Project overview
- Key features
- Quick start
- Architecture
- API integration
- Testing
- CI/CD
- Future improvements

### API Reference (`api-reference.md`)

Contains:
- Complete description of all modules
- Data types
- Functions and their parameters
- Usage examples
- Error handling

### Examples (`examples.md`)

Contains:
- Basic PGN parsing
- Advanced move parsing
- Error handling
- Zobrist hashing
- Board visualization
- API integration
- Working with multiple games
- Game analysis

### Installation (`installation.md`)

Contains:
- System requirements
- OCaml and OPAM installation
- PGN Parser installation
- Installation verification
- IDE setup
- Troubleshooting
- Development
- Docker
- CI/CD

## Customization

### Styles

Main styles are located in `assets/css/style.css`. Supported features:

- Responsive design
- Dark theme
- Syntax highlighting
- Interactive elements

### JavaScript

Functionality in `assets/js/main.js`:

- Mobile menu
- Smooth scrolling
- Code copying
- Documentation search
- Theme switching
- OCaml code highlighting

### Templates

Main template `_layouts/default.html` includes:

- Header with navigation
- Sidebar
- Main content
- Footer
- SEO meta tags
- Open Graph tags

## Deployment

### GitHub Pages

Documentation is automatically deployed to GitHub Pages when pushing to the `main` branch via the `docs.yml` workflow.

### Manual Deployment

```bash
# Build
bundle exec jekyll build

# Copy to gh-pages branch
cp -r _site/* ../gh-pages/

# Commit and push
cd ../gh-pages
git add .
git commit -m "Update documentation"
git push origin gh-pages
```

## Configuration

### Jekyll (`_config.yml`)

Main settings:
- Site name and description
- URL and base URL
- Navigation
- Plugins
- SEO settings
- Exclusions and inclusions

### GitHub Pages

Repository settings:
1. Settings → Pages
2. Source: GitHub Actions
3. Workflow: Deploy Documentation

## Support

### Issues

If you have problems with the documentation:

1. Check [Issues](https://github.com/ckaf/pgn_parser/issues)
2. Create a new issue with the `documentation` tag
3. Describe the problem in detail

### Contributing

To improve the documentation:

1. Fork the repository
2. Create a feature branch
3. Make changes
4. Test locally
5. Create a pull request

### Standards

- Use Markdown for content
- Follow existing style
- Add code examples
- Update when API changes
- Test locally before committing

## License

The documentation is distributed under the same MIT license as the main project.