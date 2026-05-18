# 🗒️ NoteNest v2

A beautifully redesigned Flutter notes app powered by **Supabase**.

---

## ✨ What Changed (v2)

| Feature | Before | After |
|---|---|---|
| **Colors** | Purple (#6C63FF) dark theme | Cyan (#22D3EE) + Pink (#F472B6) fresh theme |
| **Font** | Default Flutter font | **Poppins** (Google Fonts) |
| **Note View** | Table/row list | **Sticky-note card grid** (2-column) |
| **Search** | Not available | ✅ Live search bar |
| **Supabase** | Old credentials | New project credentials |
| **DB** | Basic schema | Enhanced with indexes, pinned field, stats view |

---

## 🎨 New Color Palette

```
Primary:    #22D3EE  (Cyan)
Secondary:  #F472B6  (Pink)
Success:    #10B981  (Emerald)
Error:      #F87171  (Red)
Background: #060818  →  #0C1130  (Deep Navy)
Surface:    #111D3C
Card:       #0F1A35
```

### Note Colors (10 vibrant picks)
`#22D3EE` `#F472B6` `#34D399` `#FB923C` `#A78BFA`
`#FBBF24` `#60A5FA` `#F87171` `#4ADE80` `#E879F9`

---

## 📁 Project Structure

```
lib/
├── config/
│   ├── supabase_config.dart   ← Supabase URL & Anon Key
│   └── app_theme.dart         ← All colors, gradients, fonts
├── models/
│   └── note_model.dart        ← Note data model
└── screens/
    ├── splash_screen.dart     ← Animated splash
    ├── login_screen.dart      ← Sign in
    ├── register_screen.dart   ← Sign up
    └── home_screen.dart       ← Card grid notepad
```

---

## 🚀 Setup

### 1. Database
Run `supabase_setup.sql` in your **Supabase SQL Editor**:
> https://qpetagirpfaptwiewjhq.supabase.co → SQL Editor

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run
```bash
flutter run
```

---

## 🔑 Supabase Config

Already set in `lib/config/supabase_config.dart`:

```dart
supabaseUrl:     'https://qpetagirpfaptwiewjhq.supabase.co'
supabaseAnonKey: 'eyJhbGci...'
```

---

## 📦 Dependencies

```yaml
supabase_flutter: ^2.3.4
google_fonts:     ^6.1.0
```
