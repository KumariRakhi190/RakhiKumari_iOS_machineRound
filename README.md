# Beauty Care App - iOS Machine Round

This is my submission for the iOS developer assignment. It's a small beauty tips app in Swift (UIKit) that shows care types, their categories and tips, using the two mobilehubs APIs.

Flow of the app:

Home (8 care types) -> Category list -> Subcategory list -> Tip detail

Home is a local list. The Category and Subcategory screens call the APIs, and Detail just shows the tip that was tapped.

## How to run

1. Clone the repo and open `RakhiiOSSkinCareApp.xcodeproj` in Xcode (15 or above).
2. Xcode will fetch the Swift packages on its own the first time, give it a minute.
3. Choose any iPhone simulator and run (Cmd+R).
4. Tests can be run with Cmd+U.

Nothing else needs to be set up. There are no keys and no config files. Minimum iOS version is 15.

## Why UIKit

I have been working with UIKit and storyboards for a long time, so I went with it. I wanted to spend my time on the actual requirements (networking, states, error handling, tests) and not on fighting a framework I'm less used to.

- The screens are in `Main.storyboard`.
- Cells have their own xibs.
- The tab bar is set up in code (`MainTabBarController`), since it's only a few lines.

## Project structure / architecture

I followed MVVM. Every screen has a ViewController and a ViewModel, and screens that need them also have models.

```
RakhiiOSSkinCareApp/
  AppLifeCycle/     AppDelegate, SceneDelegate
  SourceCode/
    HomeModule/
    CategoryModule/
    SubcategoryModule/
    DetailModule/
    FavouriteModule/
    Common/         ViewState, LocalizedContent, small helpers, tab bar
  Utilities/
    APIManager/     APIEndpoint, APIManager, NetworkError, APIResponse
    HelperClasses/  ImageLoader, OfflineCache, FavouriteManager
    Localization/   LanguageManager
    Extensions/, Loader/, Toast/
```

A few points about how it's wired:

- **ViewControllers never call the API themselves.** They call a method on the view model, like `viewModel.getCategories()`. The view model publishes its data with `@Published`, and the VC listens with Combine:
  ```swift
  viewModel.$state.sink { ... }.store(in: &viewModel.cancellable)
  ```
- **Networking is behind a `NetworkClient` protocol.** `APIManager` is the real one: `URLSession` + `async/await`, it checks the status code and decodes with `Codable`. The view models get the client in their `init` (it defaults to `APIManager.shared`), so in tests I just pass a mock.
- **`APIEndpoint` is the only place with URLs.** It's an enum that knows the base URL, the paths and the query items. No screen builds a URL string.
- **`NetworkError` turns every failure into a message for the user.** It covers no internet, timeout, bad status code, decoding failure and server message.
- **Each API screen has a `ViewState`:** `idle`, `loading`, `loaded`, `empty` or `error`. The VC switches on it to show the loader, the list, or the message with Retry.

## Things I had to handle in the API

While testing the APIs I noticed a few things:

- **String IDs:** `id` and `applicationid` come as strings, so they are `String` in the models.
- **Wrong Content-Type:** the response says `Content-Type: text/html` even though it's JSON. So I don't check the content type, I just decode the body.
- **Empty `data`:** `data` can be empty. I handle an empty, `null` or missing array as the empty state instead of treating it as an error.
- **HTML in descriptions:** descriptions have HTML (`<div>`, `<ul><li>`, `&nbsp;`, lots of `\r\n`). I wrote a small `htmlToPlainText` extension that converts list items to bullets, removes the tags, decodes entities and cleans up the extra blank lines. I used plain text on purpose, so the label keeps the system font and Dynamic Type.
- **Empty languages:** in the `language` array, some entries have an empty `name` / `description` (French is always empty). If the selected language is empty I fall back to English, and if that's empty too, to `category_name` / `subcategory_name`.
- **`subcategory_name`:** this is just "REMEDY" / "DIET" / "EXERCISE". So in the list and on detail I show the tip's actual name from the language array ("Coconut oil" etc.), which is more useful.
- **Optional fields:** all model fields are optional, so one missing field doesn't break the whole list.

## Loading / empty / error states

Both list screens have:

- **Loading:** a full-screen loader on first load, or the refresh spinner on pull to refresh.
- **Empty:** a message with a Retry button.
- **Error:** a proper message depending on what went wrong, also with Retry.

Retry just calls the API again.

## Images

I wrote a small `ImageLoader` (URLSession + `NSCache`); URLSession's `URLCache` also keeps responses on disk.

- **Spinner in each cell:** while the image is downloading the cell shows a small spinner, which goes away when the image arrives.
- **Detail screen:** same spinner on the detail image.
- **Failures:** if the download fails, a placeholder image is shown.
- **Reused cells:** cells keep track of which URL they asked for, so when a cell is reused while scrolling it doesn't show an old image.

The images on the server are quite heavy (1-3 MB each), so on a slow network they take a few seconds the first time. After that they come from the cache.

## Bonus tasks I did

- **Language switcher:** the globe button on Home lets you pick English, Hindi, Telugu or Spanish.
  - Category names, tip names and descriptions then come from the API's `language` array in that language.
  - The choice is saved in UserDefaults.
- **Favourites:** there's a heart button on the detail screen.
  - Favourite tips are saved locally in UserDefaults.
  - The Favourites tab lists them, and you can open them from there.
- **Offline cache:** every successful list response is saved as JSON in the Caches folder. If there's no internet next time, the saved list is shown along with a toast saying you're offline.
- **Search:** the search field on the category list filters while typing. It ignores case and accents and checks both the selected-language name and the English name.
- **Pull to refresh:** works on both list screens.
- **Share:** the share button on detail opens the system share sheet with the tip title and description.

## Tests

There are 16 unit tests (Cmd+U).

`ModelDecodingTests` covers:

- decoding the sample JSON (string ids, empty `audio_file`, null data)
- the language fallback
- the HTML to text conversion
- the endpoint URLs

`ViewModelTests` uses a `MockNetworkClient` and covers:

- success
- no internet
- bad status code
- decoding failure
- empty response
- retry after a failure
- showing the offline cache
- search filtering
- adding/removing a favourite

Each test gets its own temp cache folder and UserDefaults suite, so the tests don't depend on each other.

## Security

Everything goes over https. I didn't add any App Transport Security exception.

## Packages

These are added through Swift Package Manager:

- **SVProgressHUD:** the full-screen loader (`Loader.show()` / `Loader.hide()`).
- **SDWebImage and IQKeyboardManager:** these are in the package list but not used anywhere in the code. I wrote the image loading myself, since the assignment asks for our own caching. These two can be removed.

No networking library is used.

## What I skipped / would improve

- **Arabic / right-to-left:** I kept the language list to English, Hindi, Telugu and Spanish, so there's no RTL.
- **Static text:** only the API content changes with the language. Labels like screen titles and button text stay in English.
- **Dark Mode:** text uses system colors, but the backgrounds are fixed colors from the design, so Dark Mode doesn't look very different.
- **Image size:** I'd downsample the big images before caching them, to save memory.
- **Accessibility:** with more time I'd do a proper accessibility pass (VoiceOver labels on the image-only buttons).

## Time spent

Around _X_ hours in total.
