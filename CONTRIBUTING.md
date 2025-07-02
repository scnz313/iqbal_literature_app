# Contributing to Iqbal Literature

First off, thank you for considering contributing to Iqbal Literature! It's people like you that make this project a great tool for preserving and sharing Dr. Allama Iqbal's literary works.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps which reproduce the problem**
* **Provide specific examples to demonstrate the steps**
* **Describe the behavior you observed after following the steps**
* **Explain which behavior you expected to see instead**
* **Include screenshots and animated GIFs if applicable**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title**
* **Provide a step-by-step description of the suggested enhancement**
* **Provide specific examples to demonstrate the steps**
* **Describe the current behavior and explain which behavior you expected to see instead**
* **Explain why this enhancement would be useful**

### Your First Code Contribution

Unsure where to begin contributing? You can start by looking through these `beginner` and `help-wanted` issues:

* Beginner issues - issues which should only require a few lines of code
* Help wanted issues - issues which should be a bit more involved

### Pull Requests

Please follow these steps to have your contribution considered by the maintainers:

1. Follow all instructions in the template
2. Follow the styleguides
3. After you submit your pull request, verify that all status checks are passing

## Styleguides

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line
* Consider starting the commit message with an applicable emoji:
    * 🎨 `:art:` when improving the format/structure of the code
    * 🐎 `:racehorse:` when improving performance
    * 📝 `:memo:` when writing docs
    * 🐛 `:bug:` when fixing a bug
    * 🔥 `:fire:` when removing code or files
    * ✅ `:white_check_mark:` when adding tests
    * 🔒 `:lock:` when dealing with security

### Dart/Flutter Styleguide

* Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
* Use `flutter format` to format your code
* Follow Flutter best practices
* Use meaningful variable and function names
* Write clear comments for complex logic
* Follow the existing project structure

### Documentation Styleguide

* Use [Markdown](https://daringfireball.net/projects/markdown/)
* Reference methods and classes in markdown with the custom `{}` notation

## Project Structure

```
lib/
├── config/           # App configuration and routing
├── core/            # Core utilities, themes, and constants
├── data/            # Data layer (repositories, services)
├── di/              # Dependency injection
├── features/        # Feature modules (following clean architecture)
├── models/          # Data models
├── services/        # External services (API, cache, etc.)
├── utils/           # Utility functions
└── widgets/         # Reusable UI components
```

## Development Setup

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/your-username/iqbal_literature.git
   cd iqbal_literature
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Create your own Firebase project for development
   - Add your configuration files
   - Set up required Firebase services

4. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

5. **Make your changes and test**
   ```bash
   flutter test
   flutter run
   ```

6. **Commit and push**
   ```bash
   git add .
   git commit -m "Add your feature"
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request**

## Testing

* Write tests for new features
* Ensure all existing tests pass
* Use widget tests for UI components
* Use unit tests for business logic

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## Additional Notes

### Issue and Pull Request Labels

* `bug` - Something isn't working
* `enhancement` - New feature or request
* `documentation` - Improvements or additions to documentation
* `good first issue` - Good for newcomers
* `help wanted` - Extra attention is needed
* `question` - Further information is requested

Thank you for contributing to Iqbal Literature! 🙏
