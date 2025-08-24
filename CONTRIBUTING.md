# Contributing to PGN Parser

Thank you for your interest in contributing to the PGN Parser project! This document provides guidelines and information for contributors.

## Getting Started

### Prerequisites

- OCaml 4.14 or later
- OPAM 2.0 or later
- Dune 3.0 or later

### Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/ckaf/pgn_parser.git
   cd pgn_parser
   ```
3. Install dependencies:
   ```bash
   opam install . --deps-only --with-test --with-doc
   ```
4. Build the project:
   ```bash
   dune build
   ```
5. Run tests:
   ```bash
   dune runtest
   ```

## Development Workflow

### Code Style

- Follow OCaml conventions
- Use `ocamlformat` for code formatting
- Keep functions small and focused
- Add type annotations where helpful
- Write clear, descriptive function and variable names

### Testing

- Write tests for new functionality
- Ensure all tests pass before submitting
- Use property-based testing with QCheck2 when appropriate
- Test with real PGN data from Lichess and Chess.com APIs
- Include both online and offline test variants
- Test unfinished games handling when applicable

### Commit Messages

Use conventional commit format:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Build/tooling changes

### Pull Request Process

1. Create a feature branch from `main`
2. Make your changes
3. Add tests for new functionality
4. Ensure all tests pass
5. Update documentation if needed
6. Submit a pull request

### Pull Request Checklist

- [ ] Code follows project style guidelines
- [ ] Tests added for new functionality
- [ ] All tests pass
- [ ] Documentation updated
- [ ] Examples updated if needed
- [ ] No new warnings generated

## Testing Guidelines

### Property-Based Testing

Use QCheck2 for generating test data:

```ocaml
let test_property =
  QCheck2.Test.make ~name:"property_name"
    generator
    (fun input -> 
      (* test logic *)
      true)
```

### Integration Testing

Test with real PGN data:

```ocaml
let test_real_pgn () =
  let pgn = "[Event \"Test\"]\n[White \"W\"]\n[Black \"B\"]\n\n1. e4 e5" in
  match parse_game pgn with
  | Ok game -> (* assertions *)
  | Error e -> assert false

let test_unfinished_game () =
  let pgn = "[Event \"Ongoing\"]\n[White \"W\"]\n[Black \"B\"]\n\n1. e4 e5 *" in
  match parse_game pgn with
  | Ok game -> 
      assert (game.info.result = Some Ongoing)
  | Error e -> assert false
```

## Documentation

- Update README.md for user-facing changes
- Add inline documentation for complex functions
- Update examples if API changes
- Document new features in the appropriate sections

## Issue Reporting

When reporting issues, please include:

- OS and OCaml version
- Steps to reproduce
- Expected vs actual behavior
- Sample PGN data (if applicable)
- Error messages

## Questions?

Feel free to open an issue for questions or discussions about the project.

Thank you for contributing! 🎯♟️
