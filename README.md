# Beauty Care App (iOS)

A native iOS beauty-tips app written in Swift. It loads care categories and tips from two live APIs.

Flow: **Home** (8 care types) → **Category list** (`getcategory`) → **Subcategory list** (`getsubcategory`) → **Detail** (tip content).

## Setup

1. Open `RakhiiOSSkinCareApp.xcodeproj` in Xcode 15 or later.
2. Wait for Swift Package Manager to resolve the packages.
3. Select the `RakhiiOSSkinCareApp` scheme and an iPhone simulator, then press **Cmd+R**.
4. Run the unit tests with **Cmd+U**.

No API keys or manual setup are needed. The minimum iOS version is 15.0.

## UI framework: UIKit (Storyboard + XIB)

I chose UIKit because it is what I work with every day, so I could focus on architecture, networking and error handling instead of learning a new framework.

- **Storyboard:** the screens are laid out in `Main.storyboard`.
- **XIBs:** the reusable cells have their own XIB files.
- **In code:** the Favourites screen and the tab bar are built in code, because they are small and simple.

## Architecture: MVVM

```
View (UIViewController + cells)
   │  binds with Combine (@Published + sink)
   ▼
ViewModel  ──uses──▶  NetworkClient (protocol)  ◀── APIManager (URLSession, async/await)
   │                                              ◀── MockNetworkClient (tests)
   ▼
Model (Codable structs)
```

- **Views** never call the network. They call the view model (for example `viewModel.getCategories()`). They listen to its `@Published` properties with Combine (`viewModel.$state.sink { ... }.store(in: &viewModel.cancellable)`).
- **ViewModels** hold the screen state (`ViewState`: `idle`, `loading`, `loaded`, `empty`, `error`) and call the network through the `NetworkClient` protocol.
  - The client is **injected** in `init`. It defaults to `APIManager.shared`, and tests pass a mock.
  - The offline cache and favourites storage are injected the same way.
- **API layer:**
  - `APIEndpoint` is the only place that knows the base URL, paths and query items.
  - `APIManager` is a single reusable client built on `URLSession` with `async/await`. It checks the status code and decodes with `Codable`.
  - `NetworkError` turns any failure into a clear message for the user.

### Folder structure

```
RakhiiOSSkinCareApp/
├── AppLifeCycle/          AppDelegate, SceneDelegate
├── SourceCode/
│   ├── HomeModule/        Home screen (local list of 8 care types)
│   ├── CategoryModule/    Category list (getcategory API)
│   ├── SubcategoryModule/ Subcategory list (getsubcategory API)
│   ├── DetailModule/      Tip detail
│   ├── FavouriteModule/   Favourites tab
│   └── Common/            Shared models (ViewState, LocalizedContent, helpers), tab bar
└── Utilities/
    ├── APIManager/        APIEndpoint, APIManager, NetworkError, APIResponse
    ├── HelperClasses/     ImageLoader, OfflineCache, FavouriteManager
    ├── Localization/      LanguageManager
    └── Extensions/, Loader/, Toast/
```

## Handling the real API data

- **String IDs:** `id` and `applicationid` are strings, so the models use `String`.
- **Wrong Content-Type:** the server sends `Content-Type: text/html` but the body is JSON, so the MIME type is not checked. The body is always decoded as JSON.
- **Missing data:** if `data` is missing or `null`, it is treated as an empty list and the empty state is shown.
- **HTML in descriptions:** `String.htmlToPlainText` turns the HTML into readable plain text.
  - Line breaks and list items (shown as bullets) are kept.
  - HTML entities are decoded and extra blank lines are removed.
  - Plain text keeps Dynamic Type and Dark Mode working on the label.
- **Empty languages:** some languages have an empty `name` or `description`. The app falls back to **selected language → English → `category_name` / `subcategory_name`**.
- **All fields optional:** every model field is optional, so one missing field does not fail the whole response.

## States on every API screen

The Category and Subcategory screens both show:

- **Loading:** a full-screen loader, or the pull-to-refresh spinner when refreshing.
- **Empty:** a message such as "No categories found." together with a Retry button.
- **Error:** a clear message together with a Retry button. Messages cover:
  - no internet
  - timeout
  - bad status code
  - decoding failure
  - server error
- **Retry:** calls the API again.

## Images

`ImageLoader` downloads images with `URLSession` and caches them in memory with `NSCache`. `URLSession`'s own `URLCache` also caches them on disk.

- Each cell shows a small spinner until its image arrives, then hides it.
- A placeholder image is shown if the download fails.
- Each cell remembers the URL it asked for, so a reused cell never shows the wrong image.

The server images are large (1–3 MB each), so the first load can take a few seconds. After that they come from the cache.

## Bonus tasks

| Bonus | Status | How |
|---|---|---|
| Language switcher | Done (English, Hindi, Telugu, Spanish) | Globe button on Home. Category and tip names and descriptions come from the API's `language` array in the chosen language, with the fallback described above. The choice is saved in `UserDefaults`. |
| Offline cache | Done | The last successful response of each list is saved as JSON in the Caches folder (`OfflineCache`). With no internet, the saved list is shown with a toast. |
| Favourites | Done | Heart button on Detail. Tips are saved locally in `UserDefaults` (`FavouriteManager`) and listed on the **Favourites** tab. |
| Search | Done | Search field on the Category list filters as the user types, by the name in the chosen language or the English name. |
| Pull to refresh | Done | On both list screens. |
| Share | Done | Share button on Detail opens the system share sheet with the tip title and text. |

## Unit tests (Cmd+U)

`ModelDecodingTests` covers:

- decoding the sample JSON (string IDs, empty `audio_file`, `null` data)
- the language fallback
- HTML-to-text conversion
- endpoint URL building

`ViewModelTests` uses `MockNetworkClient` to cover:

- the success case
- errors: no internet, bad status code, decoding failure
- the empty state
- retry after a failure
- the offline cache fallback
- search filtering
- saving and removing favourites

Each test uses its own temporary cache folder and `UserDefaults` suite, so tests do not affect each other.

## Security

All requests use `https`. There is **no App Transport Security exception**.

## Third-party packages (Swift Package Manager)

- **SVProgressHUD:** the full-screen loading indicator (`Loader.show()` / `Loader.hide()`).
- **SDWebImage and IQKeyboardManager** are in the package list but are **not used** in the code.
  - Image loading and caching are written by hand (`ImageLoader`), as the assignment asks.
  - These two packages can be removed.

No networking library is used.

## Skipped / known limitations

- **Arabic and right-to-left layout** were not added. I kept the language list to English, Hindi, Telugu and Spanish.
- **Static UI text** (screen titles, buttons, error messages) stays in English. Only the API content changes with the language.
- **Dark Mode:** text uses system colors, but the screen backgrounds use fixed brand colours from the design, so the app looks the same in Dark Mode.
- **Image size:** the server images are not resized. With more time I would downsample them before caching, to save memory.

## Time spent

About _X_ hours. <!-- fill in -->
