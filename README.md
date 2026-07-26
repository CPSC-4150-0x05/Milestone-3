# Milestone 3

# ReadRight 2.0

ReadRight 2.0 is a Flutter-based literacy application designed to help elementary students improve reading fluency and sight-word recognition. The application combines pronunciation practice, AI-generated reading stories, and interactive Dolch sight-word games to create a personalized reading experience for both teachers and students.

---

## Features

### Pronunciation Practice
- Record student pronunciation attempts
- Automatic pronunciation scoring and feedback
- Audio playback for teacher review
- Missed word tracking
- Student progress monitoring

### AI Story Builder
- Teacher-controlled AI story generation
- Reading level selection
- Topic-based story generation
- Uses Dolch sight words for the selected reading level
- GPT-5 Mini through a secure Supabase Edge Function
- Backend proxy keeps API keys secure
- Age-appropriate content generation

### Student Story Builder
- Generates stories using the student's assigned reading level
- Automatically uses the student's current Dolch word list
- Students cannot manually change their reading level

### Flash Dash
- Interactive Dolch sight-word game
- Multiple reading levels
- Performance tracking
- Missed words recycled until mastered
- Results and statistics screen
- Progress saving

### Teacher Dashboard
- View student progress
- Search and sort students
- View missed words
- Reset student passwords
- Export class reports as CSV
- Manage word lists
- Generate AI stories for any reading level

---

## Technologies Used

- Flutter
- Dart
- Supabase
- Supabase Edge Functions
- GPT-5 Mini
- SQLite (sqflite)
- Shared Preferences
- Flutter TTS
- Audioplayers

---

## Project Architecture

The application follows a client-server architecture.

### Frontend
- Flutter
- Material Design
- Local SQLite database
- SharedPreferences for session management

### Backend
- Supabase
- Edge Functions
- OpenAI GPT-5 Mini API
- Secure environment variables

All AI requests are routed through a secure backend proxy. API keys are never stored inside the Flutter application or committed to GitHub.

---

## AI Story Builder Workflow

### Teacher

1. Select a reading level
2. Enter a story topic
3. Generate an AI story
4. Story includes Dolch words for the selected level

### Student

1. Student logs in
2. Assigned reading level is automatically loaded
3. Student enters a topic
4. Story is generated using only the student's assigned Dolch list

---

## Flash Dash Workflow

1. Select a Dolch reading level
2. Practice sight words
3. Mark words as known or practice again
4. Missed words repeat until mastered
5. Results are saved for teacher review

---

## Security

- OpenAI API key stored only in Supabase Secrets
- Flutter application never contains API keys
- All AI requests use a backend proxy
- Environment variables excluded from GitHub
- Teacher-controlled AI generation for content safety

---

## Installation

### Prerequisites

- Flutter SDK
- Dart SDK
- Supabase project
- OpenAI API key
- Git

### Clone the Repository

```bash
git clone <repository-url>
cd ReadRight-2.0
```

### Install Packages

```bash
flutter pub get
```

### Configure Supabase

Create your Supabase project and configure:

- URL
- Anonymous Key
- Edge Function
- OpenAI Secret

### Run

```bash
flutter run
```

---

## Folder Structure

```
lib/
├── data/
├── flash_dash/
├── models/
├── screens/
├── services/
├── utils/
└── widgets/
```

---

## Team Members

- Anthony Frialde
- Medelin Price
- Team 0x05

---

## Future Improvements

- Additional AI-assisted reading activities
- More Dolch word games
- Improved pronunciation analytics
- Expanded teacher reporting
- Student achievement badges
- Enhanced accessibility features

---

## Screenshots

<img width="250" height="540" alt="Simulator Screenshot - iPhone 15 Pro - 2025-12-09 at 10 33 03" src="https://github.com/user-attachments/assets/7452263e-90e7-4532-ac88-a74a9201bf8f" />
<img width="250" height="540" alt="Simulator Screenshot - iPhone 15 Pro - 2025-12-09 at 10 33 19" src="https://github.com/user-attachments/assets/6d08d4a1-98e6-48c0-91b2-dcdaa76f1398" />
<img width="250" height="540" alt="Simulator Screenshot - iPhone 15 Pro - 2025-12-09 at 10 53 00" src="https://github.com/user-attachments/assets/2b874e79-32d0-433c-bcea-e1ed230a4919" />
<img width="250" height="540" alt="Simulator Screenshot - iPhone 15 Pro - 2025-12-09 at 10 33 57" src="https://github.com/user-attachments/assets/113f3ced-f7f2-4e58-bf78-ee26b31adc17" />
<img width="250" height="540" alt="Simulator Screenshot - iPhone 15 Pro - 2025-12-09 at 10 33 28" src="https://github.com/user-attachments/assets/e58e1765-dc1e-4e2a-9010-cae0c943508f" />

This project was developed as part of Clemson University's CPSC 4150 Capstone Project.
