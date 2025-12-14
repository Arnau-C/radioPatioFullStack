<!-- Repo-specific Copilot instructions for AI coding agents -->
# Copilot Instructions — radioPatioFullStack

Purpose: Give AI agents the minimal, actionable context to be productive in this full‑stack Flutter + Spring Boot repo.

- Quick commands
  - **Run backend (Linux/macOS):** `cd backend && ./mvnw spring-boot:run`
  - **Build backend jar:** `cd backend && ./mvnw package`
  - **Run backend tests:** `cd backend && ./mvnw test`
  - **Run frontend (Flutter):** `cd frontend && flutter run`
  - **Build Flutter app:** `cd frontend && flutter build apk` (or `ios`/`web` targets)
  - **Run frontend tests:** `cd frontend && flutter test`

- High level architecture
  - Two main components: `backend/` (Spring Boot, Java 21) and `frontend/` (Flutter app).
  - Backend entrypoint: `backend/src/main/java/com/proyect/backend/BackendApplication.java`.
  - Frontend entrypoint: `frontend/lib/main.dart`.
  - The current backend is a Spring Boot app with JPA, Security, and both H2 + MySQL drivers declared in `backend/pom.xml`.
  - The repo currently contains minimal scaffold code (no REST controllers found). New API code should follow the package root `com.proyect.backend`.

- Project-specific patterns & conventions
  - Java packages use `com.proyect.backend`. Place controllers under `...controller`, services under `...service`, repositories under `...repository`, entities under `...entity`.
  - Lombok is used (annotation processors configured in `pom.xml`) — ensure the annotation processor is available when compiling.
  - Database drivers: `h2` is present for in-memory/local tests, `mysql-connector-j` is present for production-style runs. Default properties are in `backend/src/main/resources/application.properties`.

- Environment & configuration notes
  - Java version: 21 (see `pom.xml` property `<java.version>`).
  - To use MySQL instead of H2, set Spring properties (example):
    - `SPRING_DATASOURCE_URL=jdbc:mysql://host:3306/dbname`
    - `SPRING_DATASOURCE_USERNAME=user`
    - `SPRING_DATASOURCE_PASSWORD=pass`
    - Or edit `backend/src/main/resources/application.properties`.
  - Flutter SDK is required to build/run the `frontend/` app; `pubspec.yaml` lists dependencies and lints.

- Integration points to watch for
  - When adding backend controllers, expose JSON REST endpoints (Spring `@RestController`) and prefer `application/json`.
  - Frontend network code should target the backend base URL; there is no existing API client in `frontend/lib/` — add HTTP client code and platform-aware configuration (e.g., separate dev/prod base URLs).

- Tips for code edits by AI agents
  - Keep changes small and targeted to the module you edit (backend vs frontend). Run unit tests after backend changes: `./mvnw test`.
  - For Java edits, respect the `com.proyect.backend` package structure and add imports; Lombok reduces boilerplate but ensure processor is configured.
  - For Flutter edits, run `flutter analyze` and `flutter test` locally to validate; use hot reload during iterative UI work.

- Files to reference when making changes
  - `backend/pom.xml` — dependencies, Java version, build plugins.
  - `backend/src/main/java/com/proyect/backend/BackendApplication.java` — Spring Boot entrypoint.
  - `backend/src/main/resources/application.properties` — runtime properties.
  - `frontend/pubspec.yaml` — Flutter dependencies and lints.
  - `frontend/lib/main.dart` — current Flutter entrypoint and minimal UI.

If anything above is unclear or you want more detail (example controllers, example API client in Flutter, or environment examples), tell me which area to expand and I will iterate.
