# DokumentenScanner

|  |  |  |
| -- | -- | -- |
| ![Welcome](Images/welcome.png?) Welcome | ![Login](Images/login.png?)  Login | ![Dashboard](Images/dashboard.png?) Dashboard |
| ![Template Detail](Images/template_detail.png?) Template Detail] | ![Students](Images/students.png?) Students | ![Filter](Images/filter.png?) Filter |
| ![Engines](Images/engines.png?) Engines | ![Scan](Images/scan.png?) Scan | ![OCR running](Images/ocr_running.png?) OCR running |
| ![OCR color](Images/ocr_color.png?) OCR done with convidence color | ![OCR text](Images/ocr_text.png?) OCR done with convidence text | ![OCR edit](Images/ocr_edit.png?) OCR edit result|
| ![OCR edit](Images/ocr_edit_done.png?) OCR finished editing result | ![OCR result](Images/ocr_result.png?) OCR result overview | ![OCR send](Images/ocr_send.png?) OCR send |

## Wichtige Dokumentation
* [SwiftUI](https://developer.apple.com/documentation/swiftui) (sehr wichtig)
  * Tutorials: 
    * [Apple Tutorials](https://developer.apple.com/tutorials/swiftui)
    * [Hacking with Swift](https://www.hackingwithswift.com/quick-start/swiftui)
    * [SwiftUI Lab](https://swiftui-lab.com)
  * Cheat Sheet:
    * [Fucking SwiftUI](https://fuckingswiftui.com)
* [Combine](https://developer.apple.com/documentation/combine) (wichtig)
  * Bücher:
    * [Using Combine](https://heckj.github.io/swiftui-notes/)
* [Vision](https://developer.apple.com/documentation/vision) (wichtig)
* [Praktikums Bericht](https://github.com/SteinerHannes/Praktikumsbericht/blob/master/Beleg.pdf) (sehr wichtig)
  * Gibt Hinweise zum Funktionsumfang
  * Gibt Hinweise zur Architektur-Struktur - Quellen:
    * [Redux-like state container in SwiftUI. Basics.](https://swiftwithmajid.com/2019/09/18/redux-like-state-container-in-swiftui/)
    * [Redux-like state container in SwiftUI. Best practices.](https://swiftwithmajid.com/2019/09/25/redux-like-state-container-in-swiftui-part2/)
    * [Redux-like state container in SwiftUI. Container Views.](https://swiftwithmajid.com/2019/10/02/redux-like-state-container-in-swiftui-part3/)
    * Es würde sich auf lange Sicht lohnen [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) anstelle der aktuellen Architektur zu verwenden

## Erklärung der Projekt-Struktur und deren Datein
* `.gitignore`: enthält eine Beschreibung für [Git](https://git-scm.com)
* `.swiftlint.yml`: Definition von code conventions mithilfe von [SwiftLint](https://github.com/realm/SwiftLint#swiftlint)
* `DokumentenScanner`: Projekt-Ordner
  * `Mock`: Test und Preview Obejekte
  * `Start`: App-Livecycle
  * `Views`: Benutzeroberflächen (erste View ist `ContentView` ! )
  * `Store`: Geschäftslogik
  * `Extensions`: Typen-Erweiterungen (Farben)
  * `Classes`: Datentypen, Texterkennung, Internet

## Hinweise zum Store-Ordner

  ### Ordner Struktur
  * `Store`: Die Store-Klasse 
  * `States`: Alles States der Anwendung (siehe nächste Abschnitt States Struktur)
  * `DTO`: Data Transfer Object, also alle Strukturen die per JSON vom Server kommen oder an der Server gesendet werden.
  * `Services`: Alle Services die zur Kommunikation mit dem Server gehören. Bsp. Senden und Empfangen von Bildern.

  ### States Struktur
  * `AppStore`: Enhält alle anderen States und wichtige globale Variablen und Actions sowie das globale Environment 
    * `Routing`: Enhält Variablen und Actions zum Wechsel zwischen Views (wird nur für den Fall der Scanner-View benötigt, alles anders läuft über `@Binding` und könnte unter iOS 14 durch `switch case` ersetzt werden)
    * `NewTemplate`: Varaiblen und Actions rund um den Ablauf beim erstellen eines neuen Templates
      * `Links`: Gehört zum Erstellen eines neuen Templates, ist speziell für die Links vorgesehen
    * `Auth`: Registrieren, Login, Logout
    * `ServiceState`: State zum Abwickeln von Server-Aufrufen / -Rückrufen
    * `OCRState`: Online und (Offline) Texterkennung
    * `Log`: Actions und Variablen zum Loggen der Anwendung und zum senden der Ergebnisse an den Server
