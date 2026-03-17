# Gemini Code Assistant Context

This document provides context for the Gemini Code Assistant to understand the project structure, technologies, and conventions.

## Project Overview

This is a full-stack application consisting of a Java/Spring Boot backend and a Flutter frontend. The project is named "radioPatioFullStack".

### Backend (Java/Spring Boot)

The backend is a Spring Boot application.

-   **Framework:** Spring Boot
-   **Language:** Java
-   **Build Tool:** Maven
-   **Key Dependencies:**
    -   `spring-boot-starter-web`: For building web, including RESTful, applications.
    -   `spring-boot-starter-data-jpa`: For data persistence.
    -   `spring-boot-starter-security`: For security.
    -   `mysql-connector-j`: MySQL database driver.
    -   `jjwt`: For JWT authentication.

### Frontend (Flutter)

The frontend is a Flutter application.

-   **Framework:** Flutter
-   **Language:** Dart
-   **Key Dependencies:**
    -   `http`: For making HTTP requests to the backend.
    -   `flutter_secure_storage`: For securely storing data like authentication tokens.

## How to Run

### Backend

To run the backend, navigate to the `backend` directory and use the Maven wrapper:

```bash
cd backend
./mvnw spring-boot:run
```

### Frontend

To run the frontend, navigate to the `frontend` directory and use the Flutter CLI:

```bash
cd frontend
flutter run
```

## Development Conventions

-   **Backend:** Follows standard Spring Boot conventions.
-   **Frontend:** Follows standard Flutter and Dart conventions.
-   **API:** The frontend communicates with the backend via a REST API.
-   **Authentication:** The application uses JWT for authentication. The frontend stores the token in secure storage.
