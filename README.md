# Alice - API Interceptor Plugin (Minimal QA Version)

Alice interceptor is a lightweight HTTP inspector for Flutter applications. This modified version is tailored specifically for **QA engineers** and developers by providing essential features for API debugging. It includes a **shake sensor** to open API logs and a **Copy cURL** feature to reproduce requests effortlessly.

---

## Features

- Intercept and display HTTP requests and responses.
- **Copy cURL command**: Quickly copy a request as a cURL command for testing or sharing.
- Minimal interface, retaining only essential features for **QA workflows**.
- **Shake to open logs**: Access the inspector by simply shaking the device.

---

## Getting Started

### Installation

Add the plugin to your `pubspec.yaml` file:

```yaml
dependencies:
  alice_interceptor:
     git:
       url: https://github.com/ksadanand172/alice_interceptor
