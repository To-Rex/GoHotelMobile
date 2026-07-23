# Graph Report - .  (2026-07-20)

## Corpus Check
- 108 files · ~120,223 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 749 nodes · 915 edges · 54 communities (49 shown, 5 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 37 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Shared UI Widgets & Nav
- Controllers & Data Loading
- M3 Color Palette (Dart)
- GoHotel API Documentation
- Home Dashboard & Stats
- GetX Controllers & Pages
- App Theme & Text Styles
- Routing & Local Storage
- Flutter Plugin Metadata
- User Model
- Data Service Layer
- API Service
- iOS App Delegate
- Task Model & Checklist
- Main Shell Binding
- App Routes
- Auth Controller
- GetX Bindings
- Report Module
- Tasks Controller
- Notifications Module
- Design: Room Checklist
- Notification Model
- Dio API Client
- Problem Report Model
- Design: Notifications
- Design: Home Dashboard
- Design: Profile Screen
- Design: Photo Report
- Design: My Tasks
- Profile Page UI
- App Constants
- Room Details Page UI
- Photo Report Page UI
- Design: Issue Report
- App Header Widget
- Tasks Page UI
- Design: Login Screen
- CocoaPods Frameworks Script
- Notification API Endpoints
- Tasks Binding
- Widget Test
- Android MainActivity
- Default App Icons
- ImagePicker Pod Stub
- Runner Pod Stub
- RunnerTests Pod Stub
- Launch Screen Readme

## God Nodes (most connected - your core abstractions)
1. `Hospitality Excellence System Design` - 11 edges
2. `gohotels Flutter Package Manifest` - 10 edges
3. `Task Entity` - 9 edges
4. `Bildirishnomalar Notifications Page (Housekeeping Pro)` - 9 edges
5. `Fotohisobot Yuborish (Photo Report Submission) Page` - 9 edges
6. `Room Details & Cleaning Checklist Screen (Xona Tafsilotlari)` - 9 edges
7. `Bosh Sahifa (Home Screen) HTML Prototype` - 8 edges
8. `Profile & Settings Screen (Profil va Sozlamalar)` - 8 edges
9. `TasksController` - 7 edges
10. `My Tasks Screen (Mening Vazifalarim)` - 7 edges

## Surprising Connections (you probably didn't know these)
- `Progress Indicators` --semantically_similar_to--> `PUT /api/v1/tasks/{id}/progress`  [INFERRED] [semantically similar]
  DesiginExample/hospitality_excellence_system/DESIGN.md → API_DOCS.md
- `Room Cards (Xona Kartochkalari)` --semantically_similar_to--> `Task Entity`  [INFERRED] [semantically similar]
  DesiginExample/hospitality_excellence_system/DESIGN.md → API_DOCS.md
- `Checklist Items Component` --semantically_similar_to--> `ChecklistItem Entity`  [INFERRED] [semantically similar]
  DesiginExample/hospitality_excellence_system/DESIGN.md → API_DOCS.md
- `Room Status Colors (Tozalangan/Tayyor/Jarayonda/Muammo/Tozalanishi kerak)` --semantically_similar_to--> `TaskStatus Enum (pending, inProgress, completed)`  [INFERRED] [semantically similar]
  DesiginExample/hospitality_excellence_system/DESIGN.md → API_DOCS.md
- `Screen Screenshot (broken: FIFE image failed to fetch)` --references--> `Issue Report Screen (Muammo haqida xabar berish)`  [AMBIGUOUS]
  DesiginExample/muammo_haqida_xabar_berish/screen.png → DesiginExample/muammo_haqida_xabar_berish/code.html

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Housekeeping Task Lifecycle (fetch, start, progress, checklist, report)** — api_docs_get_tasks, api_docs_start_task, api_docs_update_task_progress, api_docs_toggle_checklist_item, api_docs_submit_photo_report, api_docs_task_entity [EXTRACTED 1.00]
- **Notification Retrieval and Read-State Management** — api_docs_get_notifications, api_docs_mark_notification_read, api_docs_mark_all_notifications_read, api_docs_notification_entity [EXTRACTED 1.00]
- **Hospitality Excellence Design System (tokens and components)** — desiginexample_hospitality_excellence_system_design_color_palette, desiginexample_hospitality_excellence_system_design_typography, desiginexample_hospitality_excellence_system_design_rounded_shapes, desiginexample_hospitality_excellence_system_design_room_cards, desiginexample_hospitality_excellence_system_design_buttons, desiginexample_hospitality_excellence_system_design_status_badges [EXTRACTED 1.00]
- **Severity-Coded Notification Triage UI** — desiginexample_bildirishnomalar_code_notification_card, desiginexample_bildirishnomalar_code_notification_severity_coding, desiginexample_bildirishnomalar_code_material_design_tokens, desiginexample_bildirishnomalar_code_swipe_micro_interaction [INFERRED 0.85]
- **Housekeeping App Screen Shell (Header + Content + Bottom Nav)** — desiginexample_bildirishnomalar_code_top_app_bar, desiginexample_bildirishnomalar_code_bottom_nav_bar, desiginexample_bildirishnomalar_code_notifications_page, desiginexample_bildirishnomalar_screen_notifications_screen [INFERRED 0.75]
- **Bosh Sahifa Staff Dashboard Layout** — desiginexample_bosh_sahifa_code_top_app_bar, desiginexample_bosh_sahifa_code_hero_completion, desiginexample_bosh_sahifa_code_stats_grid, desiginexample_bosh_sahifa_code_tasks_feed, desiginexample_bosh_sahifa_code_bottom_nav_bar [EXTRACTED 1.00]
- **Housekeeping Photo Report Submission Flow** — desiginexample_fotohisobot_yuborish_code_room_info_card, desiginexample_fotohisobot_yuborish_code_photo_upload_grid, desiginexample_fotohisobot_yuborish_code_comments_section, desiginexample_fotohisobot_yuborish_code_action_buttons, desiginexample_fotohisobot_yuborish_code_submit_interaction_script [INFERRED 0.85]
- **Login Interaction Flow (submit -> loading state -> success modal -> redirect)** — desiginexample_kirish_sahifasi_code_login_form, desiginexample_kirish_sahifasi_code_toggle_password, desiginexample_kirish_sahifasi_code_success_modal [EXTRACTED 1.00]
- **Tab-based Task Filtering Flow** — desiginexample_mening_vazifalarim_code_tab_navigation, desiginexample_mening_vazifalarim_code_switchtab, desiginexample_mening_vazifalarim_code_task_card, desiginexample_mening_vazifalarim_code_empty_state [EXTRACTED 1.00]
- **Hotel Issue Reporting Flow** — desiginexample_muammo_haqida_xabar_berish_code_category_selector, desiginexample_muammo_haqida_xabar_berish_code_comment_field, desiginexample_muammo_haqida_xabar_berish_code_photo_upload, desiginexample_muammo_haqida_xabar_berish_code_submit_flow [EXTRACTED 1.00]
- **Profile & Settings Screen Composition** — desiginexample_profil_va_sozlamalar_code_top_app_bar, desiginexample_profil_va_sozlamalar_code_profile_header_card, desiginexample_profil_va_sozlamalar_code_settings_list, desiginexample_profil_va_sozlamalar_code_stats_section, desiginexample_profil_va_sozlamalar_code_logout_section, desiginexample_profil_va_sozlamalar_code_bottom_nav_bar [EXTRACTED 1.00]
- **Material 3 Token-Driven Styling of Screen Sections** — desiginexample_profil_va_sozlamalar_code_tailwind_theme_tokens, desiginexample_profil_va_sozlamalar_code_profile_header_card, desiginexample_profil_va_sozlamalar_code_settings_list, desiginexample_profil_va_sozlamalar_code_stats_section [INFERRED 0.85]
- **Checklist Completion Flow (check tasks -> progress -> complete -> success)** — desiginexample_xona_tafsilotlari_va_chek_list_code_task_card, desiginexample_xona_tafsilotlari_va_chek_list_code_update_progress_logic, desiginexample_xona_tafsilotlari_va_chek_list_code_progress_bar, desiginexample_xona_tafsilotlari_va_chek_list_code_complete_fab, desiginexample_xona_tafsilotlari_va_chek_list_code_success_overlay [EXTRACTED 1.00]
- **Room Context Summary for Housekeeping Staff** — desiginexample_xona_tafsilotlari_va_chek_list_code_header_bar, desiginexample_xona_tafsilotlari_va_chek_list_code_room_identity_bento, desiginexample_xona_tafsilotlari_va_chek_list_code_guest_note [INFERRED 0.85]

## Communities (54 total, 5 thin omitted)

### Community 0 - "Shared UI Widgets & Nav"
Cohesion: 0.05
Nodes (43): ../../../app/theme/text_styles.dart, Color, IconData, AppHeader, AppBottomNavBar, build, currentIndex, filled (+35 more)

### Community 1 - "Controllers & Data Loading"
Cohesion: 0.05
Nodes (38): ../../../data/services/data_service.dart, ../../home/controllers/main_controller.dart, ImagePicker, int get, _dataService, isLoading, loadNotifications, markAllAsRead (+30 more)

### Community 2 - "M3 Color Palette (Dart)"
Cohesion: 0.05
Nodes (40): AppColors, error, errorContainer, inverseOnSurface, inversePrimary, inverseSurface, onError, onErrorContainer (+32 more)

### Community 3 - "GoHotel API Documentation"
Cohesion: 0.07
Nodes (39): Dart Analyzer Configuration, GoHotel API Documentation, Bearer Token Authentication, ChecklistItem Entity, Error Response Format, GET /api/v1/tasks/{id}, GET /api/v1/tasks, Problem Category Values (+31 more)

### Community 4 - "Home Dashboard & Stats"
Cohesion: 0.06
Nodes (31): ../../../core/widgets/stat_card.dart, CustomPainter, dart:math, completedTasks, _dataService, HomeController, _initApp, isLoading (+23 more)

### Community 5 - "GetX Controllers & Pages"
Cohesion: 0.08
Nodes (29): GetView, GetxController, AuthController, LoginPage, NotificationsController, NotificationsPage, _dataService, isLoading (+21 more)

### Community 6 - "App Theme & Text Styles"
Cohesion: 0.07
Nodes (26): colors.dart, ../controllers/auth_controller.dart, AppTheme, light, AppTextStyles, bodyLg, bodyMd, h1 (+18 more)

### Community 7 - "Routing & Local Storage"
Cohesion: 0.07
Nodes (26): app/routes/app_routes.dart, app/theme/app_theme.dart, bool get, GetStorage, _box, clear, init, _instance (+18 more)

### Community 8 - "Flutter Plugin Metadata"
Cohesion: 0.08
Nodes (25): authors, Flutter Dev Team, dependencies, Flutter, description, documentation_url, homepage, license (+17 more)

### Community 9 - "User Model"
Cohesion: 0.09
Nodes (22): avatarUrl, branchId, department, displayName, email, firstName, fromJson, hotelId (+14 more)

### Community 10 - "Data Service Layer"
Cohesion: 0.10
Nodes (20): api_client.dart, api_service.dart, _api, DataService, getCurrentUser, getNotifications, getProfile, getTask (+12 more)

### Community 11 - "API Service"
Cohesion: 0.10
Nodes (20): ApiService, _client, getMe, getNotifications, getProfile, getTask, getTasks, login (+12 more)

### Community 12 - "iOS App Delegate"
Cohesion: 0.11
Nodes (14): Any, Bool, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate (+6 more)

### Community 13 - "Task Model & Checklist"
Cohesion: 0.10
Nodes (19): checklist, ChecklistItem, copyWith, deadline, floor, fromJson, guest, guestStatus (+11 more)

### Community 14 - "Main Shell Binding"
Cohesion: 0.12
Nodes (14): ../controllers/main_controller.dart, ../../../core/widgets/bottom_nav_bar.dart, home_controller.dart, ../../home/views/home_page.dart, dependencies, MainBinding, changeTab, currentIndex (+6 more)

### Community 15 - "App Routes"
Cohesion: 0.12
Nodes (16): AppRoutes, routes, ../../modules/auth/bindings/auth_binding.dart, ../../modules/auth/views/login_page.dart, ../../modules/home/bindings/home_binding.dart, ../../modules/home/bindings/main_binding.dart, ../../modules/home/views/main_page.dart, ../../modules/notifications/bindings/notifications_binding.dart (+8 more)

### Community 16 - "Auth Controller"
Cohesion: 0.12
Nodes (16): _dataService, isLoading, isLoggedIn, isPasswordVisible, loadSavedData, login, logout, onInit (+8 more)

### Community 17 - "GetX Bindings"
Cohesion: 0.15
Nodes (12): Bindings, ../controllers/home_controller.dart, ../controllers/profile_controller.dart, AuthBinding, dependencies, dependencies, HomeBinding, dependencies (+4 more)

### Community 18 - "Report Module"
Cohesion: 0.15
Nodes (12): ../controllers/photo_report_controller.dart, ../controllers/problem_report_controller.dart, ../../../data/models/task_model.dart, dependencies, build, _buildCategoryGrid, _buildDescriptionField, _buildHeaderCard (+4 more)

### Community 19 - "Tasks Controller"
Cohesion: 0.14
Nodes (13): changeTab, completedTasks, _dataService, inProgressTasks, isLoading, loadTasks, onInit, pendingTasks (+5 more)

### Community 20 - "Notifications Module"
Cohesion: 0.15
Nodes (11): ../controllers/notifications_controller.dart, ../../../data/models/notification_model.dart, NotificationModel, dependencies, NotificationsBinding, build, _buildActionButton, _buildHeader (+3 more)

### Community 21 - "Design: Room Checklist"
Cohesion: 0.22
Nodes (13): Floating Pill Bottom Navigation (Vazifalar, Xabarlar, Profil), Cleaning Checklist (Tozalash Chek-listi), Complete Floating Action Button (check_circle), Material 3 Style Tailwind Design Tokens, Guest Note Callout (Eslatma: Guest Returns 14:00), Top Navigation Header (Xona 402, Hisobot Camera Action), Cleaning Progress Bar (Jarayon %), Room Details & Cleaning Checklist Screen (Xona Tafsilotlari) (+5 more)

### Community 22 - "Notification Model"
Cohesion: 0.15
Nodes (12): copyWith, fromJson, hasActions, id, isRead, message, NotificationType, roomNumber (+4 more)

### Community 23 - "Dio API Client"
Cohesion: 0.17
Nodes (11): ../../../core/storage/local_storage.dart, Dio, Dio get, Interceptor, ApiClient, _AuthInterceptor, baseUrl, _dio (+3 more)

### Community 24 - "Problem Report Model"
Cohesion: 0.17
Nodes (11): DateTime, category, createdAt, description, fromJson, id, photoPaths, ProblemReportModel (+3 more)

### Community 25 - "Design: Notifications"
Cohesion: 0.21
Nodes (12): BottomNavBar Floating Pill Navigation, GoHotel Service App Brand, Inter Typeface, Material 3 Design Token System (Tailwind Config), Material Symbols Outlined Icon Font, Notification Card Component, Notification Severity Color Coding, Bildirishnomalar Notifications Page (Housekeeping Pro) (+4 more)

### Community 26 - "Design: Home Dashboard"
Cohesion: 0.21
Nodes (12): Bosh Sahifa (Home Screen) HTML Prototype, Floating BottomNavBar (Bosh, Vazifalar, Hisobot, Xabarlar, Profil), GoHotel Service Staff App (Housekeeping Task Management), Hero Section: Shift Completion Circular Progress (75%), Material Design 3 Color Token System, Room Task Card Pattern (Status Badge, Progress Bar, Action Button), Stats Grid (Yakunlandi 12 / Kutilmoqda 4 / Muammo 1), Tailwind Theme Config (M3 Color Tokens, Typography Scale) (+4 more)

### Community 27 - "Design: Profile Screen"
Cohesion: 0.24
Nodes (12): BottomNavBar (Floating Pill: Home, Tasks, Report, Messages, Profile), Glassmorphism Style (glass-card, profile-mesh gradients), Housekeeper Employee Profile (Malika Axmedova, #HP-90234, Xizmat ko'rsatish dept), Log Out Section (Chiqish Button + Version 2.4.0 Build 89), Profile Header Card (Asymmetric Bento, Employee Info), Profile & Settings Screen (Profil va Sozlamalar), Ripple Micro-Interaction Script, Settings List (Tizim sozlamalari: Language, Privacy, Help) (+4 more)

### Community 28 - "Design: Photo Report"
Cohesion: 0.24
Nodes (11): Action Buttons (Hisobotni Yuborish / Bekor Qilish), Floating Pill BottomNavBar (Home, Tasks, Scanner, Alerts, Profile), Optional Comment Textarea Section, Fotohisobot Yuborish (Photo Report Submission) Page, Housekeeping Pro / GoHotel Service Brand System, Photo Upload Grid (Bed / Bathroom / General View Slots), Room Info Card (Room 402, Standart Lyuks), Submit Micro-Interaction Script (Spinner + Success Alert) (+3 more)

### Community 29 - "Design: My Tasks"
Cohesion: 0.20
Nodes (11): Bottom Navigation Bar (Floating Pill), Empty State (No Tasks), GoHotel Service / Housekeeping Pro App, Material Symbols Outlined Icons, Material Design 3 Color Token Theme (Tailwind Config), My Tasks Screen (Mening Vazifalarim), switchTab Function, Task Status Tabs (Kutilmoqda / Jarayonda / Yakunlangan) (+3 more)

### Community 30 - "Profile Page UI"
Cohesion: 0.20
Nodes (9): ../../../core/constants/app_constants.dart, build, _buildLogoutButton, _buildProfileCard, _buildSettingsCard, _buildStatsCard, _buildVersion, _infoColumn (+1 more)

### Community 31 - "App Constants"
Cohesion: 0.20
Nodes (9): AppConstants, appName, appVersion, buildNumber, languages, problemCategories, supportPhone, static const List (+1 more)

### Community 32 - "Room Details Page UI"
Cohesion: 0.22
Nodes (8): ../../../app/theme/colors.dart, build, _buildChecklist, _buildCompleteButton, _buildInfoGrid, _buildNote, RoomDetailsPage, _statusText

### Community 33 - "Photo Report Page UI"
Cohesion: 0.22
Nodes (8): dart:io, build, _buildCancelButton, _buildCommentsField, _buildPhotoGrid, _buildRoomInfo, _buildSubmitButton, _buildUploadedSamples

### Community 34 - "Design: Issue Report"
Cohesion: 0.25
Nodes (9): Problem Category Selector (Siniq buyum, Texnik nosozlik, Suv sizishi, Boshqa), Comment Textarea (IZOH), Issue Report Form, Issue Report Screen (Muammo haqida xabar berish), Material 3 Color Token Tailwind Config, Photo Upload Section (max 3 images), Simulated Submit Flow (send -> spinner -> success -> back), Top App Bar with Back Navigation (+1 more)

### Community 35 - "App Header Widget"
Cohesion: 0.22
Nodes (8): actions, build, showAvatar, showBackButton, subtitle, title, List, String?

### Community 36 - "Tasks Page UI"
Cohesion: 0.25
Nodes (7): ../../../core/widgets/app_header.dart, ../../../core/widgets/empty_state.dart, ../../../core/widgets/task_card.dart, build, _buildTab, _buildTabBar, _buildTabContent

### Community 37 - "Design: Login Screen"
Cohesion: 0.29
Nodes (8): Glassmorphism Card Style with Interactive Radial Gradient Background, Language Switcher (O'zbek / Russian / English), Login Form (identifier + password + remember me), GoHotel Service Login Page (Kirish), Success Modal (Muvaffaqiyatli), Tailwind Material 3 Theme Config (color tokens, type scale, spacing), togglePassword Function, Login Screen Mockup (mobile portrait: logo, phone/employee-ID field, password with visibility toggle, Kirish CTA, language row, support footer)

### Community 38 - "CocoaPods Frameworks Script"
Cohesion: 0.43
Nodes (6): code_sign_if_enabled(), install_bcsymbolmap(), install_dsym(), install_framework(), Pods-Runner-frameworks.sh script, strip_invalid_archs()

### Community 39 - "Notification API Endpoints"
Cohesion: 0.40
Nodes (5): GET /api/v1/notifications, PUT /api/v1/notifications/read-all, PUT /api/v1/notifications/{id}/read, Notification Entity, NotificationType Enum (critical, newTask, problemAccepted, inventory, system)

### Community 40 - "Tasks Binding"
Cohesion: 0.50
Nodes (3): ../controllers/tasks_controller.dart, dependencies, TasksBinding

### Community 41 - "Widget Test"
Cohesion: 0.50
Nodes (3): package:flutter_test/flutter_test.dart, package:gohotels/main.dart, main

### Community 43 - "Default App Icons"
Cohesion: 0.67
Nodes (3): Android Launcher Icon (Default Flutter Logo), iOS App Icon (Default Flutter Logo), iOS Launch Image (Blank Default)

## Ambiguous Edges - Review These
- `Issue Report Screen (Muammo haqida xabar berish)` → `Screen Screenshot (broken: FIFE image failed to fetch)`  [AMBIGUOUS]
  DesiginExample/muammo_haqida_xabar_berish/screen.png · relation: references

## Knowledge Gaps
- **445 isolated node(s):** `name`, `version`, `summary`, `description`, `homepage` (+440 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `Issue Report Screen (Muammo haqida xabar berish)` and `Screen Screenshot (broken: FIFE image failed to fetch)`?**
  _Edge tagged AMBIGUOUS (relation: references) - confidence is low._
- **Why does `TaskModel` connect `Shared UI Widgets & Nav` to `Controllers & Data Loading`, `Task Model & Checklist`?**
  _High betweenness centrality (0.010) - this node is a cross-community bridge._
- **Why does `NotificationModel` connect `Notifications Module` to `Notification Model`?**
  _High betweenness centrality (0.009) - this node is a cross-community bridge._
- **Why does `TasksController` connect `GetX Controllers & Pages` to `Room Details Page UI`, `Controllers & Data Loading`, `Tasks Controller`, `Home Dashboard & Stats`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **What connects `name`, `version`, `summary` to the rest of the system?**
  _445 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Shared UI Widgets & Nav` be split into smaller, more focused modules?**
  _Cohesion score 0.04902867715078631 - nodes in this community are weakly interconnected._
- **Should `Controllers & Data Loading` be split into smaller, more focused modules?**
  _Cohesion score 0.05121951219512195 - nodes in this community are weakly interconnected._