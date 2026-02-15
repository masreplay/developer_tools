import 'package:developer_tools_network/network_inspector/model/network_translation.dart';

/// Class used to manage translations in NetworkInspector.
class NetworkTranslations {
  /// Contains list of translation data for all languages.
  static final List<NetworkTranslationData> _translations = _initialize();

  /// Initializes translation data for all languages.
  static List<NetworkTranslationData> _initialize() {
    List<NetworkTranslationData> translations = [];
    translations.add(_buildEnTranslations());
    translations.add(_buildPlTranslations());
    return translations;
  }

  /// Builds [NetworkTranslationData] for english language.
  static NetworkTranslationData _buildEnTranslations() {
    return NetworkTranslationData(
      languageCode: 'en',
      values: {
        NetworkTranslationKey.networkInspector: 'Network',
        NetworkTranslationKey.callDetails: 'HTTP Call Details',
        NetworkTranslationKey.emailSubject: 'NetworkInspector report',
        NetworkTranslationKey.callDetailsRequest: 'Request',
        NetworkTranslationKey.callDetailsResponse: 'Response',
        NetworkTranslationKey.callDetailsOverview: 'Overview',
        NetworkTranslationKey.callDetailsError: 'Error',
        NetworkTranslationKey.callDetailsEmpty: 'Loading data failed',
        NetworkTranslationKey.callErrorScreenErrorEmpty: 'Error is empty',
        NetworkTranslationKey.callErrorScreenError: 'Error:',
        NetworkTranslationKey.callErrorScreenStacktrace: 'Stack trace:',
        NetworkTranslationKey.callErrorScreenEmpty: 'Nothing to display here',
        NetworkTranslationKey.callOverviewMethod: 'Method:',
        NetworkTranslationKey.callOverviewServer: 'Server:',
        NetworkTranslationKey.callOverviewEndpoint: 'Endpoint:',
        NetworkTranslationKey.callOverviewStarted: 'Started:',
        NetworkTranslationKey.callOverviewFinished: 'Finished:',
        NetworkTranslationKey.callOverviewDuration: 'Duration:',
        NetworkTranslationKey.callOverviewBytesSent: 'Bytes sent:',
        NetworkTranslationKey.callOverviewBytesReceived: 'Bytes received:',
        NetworkTranslationKey.callOverviewClient: 'Client:',
        NetworkTranslationKey.callOverviewSecure: 'Secure:',
        NetworkTranslationKey.callRequestStarted: 'Started:',
        NetworkTranslationKey.callRequestBytesSent: 'Bytes sent:',
        NetworkTranslationKey.callRequestContentType: 'Content type:',
        NetworkTranslationKey.callRequestBody: 'Body:',
        NetworkTranslationKey.callRequestBodyEmpty: 'Body is empty',
        NetworkTranslationKey.callRequestFormDataFields: 'Form data fields:',
        NetworkTranslationKey.callRequestFormDataFiles: 'Form files:',
        NetworkTranslationKey.callRequestHeaders: 'Headers:',
        NetworkTranslationKey.callRequestHeadersEmpty: 'Headers are empty',
        NetworkTranslationKey.callRequestQueryParameters: 'Query parameters',
        NetworkTranslationKey.callRequestQueryParametersEmpty:
            'Query parameters are empty',
        NetworkTranslationKey.callResponseWaitingForResponse:
            'Awaiting response...',
        NetworkTranslationKey.callResponseError: 'Error',
        NetworkTranslationKey.callResponseReceived: 'Received:',
        NetworkTranslationKey.callResponseBytesReceived: 'Bytes received:',
        NetworkTranslationKey.callResponseStatus: 'Status:',
        NetworkTranslationKey.callResponseHeaders: 'Headers:',
        NetworkTranslationKey.callResponseHeadersEmpty: 'Headers are empty',
        NetworkTranslationKey.callResponseBodyImage: 'Body: Image',
        NetworkTranslationKey.callResponseBody: 'Body:',
        NetworkTranslationKey.callResponseTooLargeToShow: 'Too large to show',
        NetworkTranslationKey.callResponseBodyShow: 'Show body',
        NetworkTranslationKey.callResponseLargeBodyShowWarning:
            'Warning! It will take some time to render output.',
        NetworkTranslationKey.callResponseBodyVideo: 'Body: Video',
        NetworkTranslationKey.callResponseBodyVideoWebBrowser:
            'Open video in web browser',
        NetworkTranslationKey.callResponseHeadersUnknown: 'Unknown',
        NetworkTranslationKey.callResponseBodyUnknown:
            'Unsupported body. Network'
            ' can render video/image/text body. Response has Content-Type: '
            "[contentType] which can't be handled. If you're feeling lucky you "
            'can try button below to try render body as text, but it may fail.',
        NetworkTranslationKey.callResponseBodyUnknownShow:
            'Show unsupported body',
        NetworkTranslationKey.callsListInspector: 'Inspector',
        NetworkTranslationKey.callsListLogger: 'Logger',
        NetworkTranslationKey.callsListDeleteLogsDialogTitle: 'Delete logs',
        NetworkTranslationKey.callsListDeleteLogsDialogDescription:
            'Do you want to clear logs?',
        NetworkTranslationKey.callsListYes: 'Yes',
        NetworkTranslationKey.callsListNo: 'No',
        NetworkTranslationKey.callsListDeleteCallsDialogTitle: 'Delete calls',
        NetworkTranslationKey.callsListDeleteCallsDialogDescription:
            'Do you want to delete HTTP calls?',
        NetworkTranslationKey.callsListSearchHint: 'Search HTTP call...',
        NetworkTranslationKey.callsListSort: 'Sort',
        NetworkTranslationKey.callsListDelete: 'Delete',
        NetworkTranslationKey.callsListStats: 'Stats',
        NetworkTranslationKey.callsListSave: 'Save',
        NetworkTranslationKey.logsEmpty: 'There are no logs to show',
        NetworkTranslationKey.logsError: 'Failed to display error',
        NetworkTranslationKey.logsItemError: 'Error:',
        NetworkTranslationKey.logsItemStackTrace: 'Stack trace:',
        NetworkTranslationKey.logsCopied: 'Copied to clipboard.',
        NetworkTranslationKey.sortDialogTitle: 'Select filter',
        NetworkTranslationKey.sortDialogAscending: 'Ascending',
        NetworkTranslationKey.sortDialogDescending: 'Descending',
        NetworkTranslationKey.sortDialogAccept: 'Accept',
        NetworkTranslationKey.sortDialogCancel: 'Cancel',
        NetworkTranslationKey.sortDialogTime: 'Create time (default)',
        NetworkTranslationKey.sortDialogResponseTime: 'Response time',
        NetworkTranslationKey.sortDialogResponseCode: 'Response code',
        NetworkTranslationKey.sortDialogResponseSize: 'Response size',
        NetworkTranslationKey.sortDialogEndpoint: 'Endpoint',
        NetworkTranslationKey.statsTitle: 'Stats',
        NetworkTranslationKey.statsTotalRequests: 'Total requests:',
        NetworkTranslationKey.statsPendingRequests: 'Pending requests:',
        NetworkTranslationKey.statsSuccessRequests: 'Success requests:',
        NetworkTranslationKey.statsRedirectionRequests: 'Redirection requests:',
        NetworkTranslationKey.statsErrorRequests: 'Error requests:',
        NetworkTranslationKey.statsBytesSent: 'Bytes sent:',
        NetworkTranslationKey.statsBytesReceived: 'Bytes received:',
        NetworkTranslationKey.statsAverageRequestTime: 'Average request time:',
        NetworkTranslationKey.statsMaxRequestTime: 'Max request time:',
        NetworkTranslationKey.statsMinRequestTime: 'Min request time:',
        NetworkTranslationKey.statsGetRequests: 'GET requests:',
        NetworkTranslationKey.statsPostRequests: 'POST requests:',
        NetworkTranslationKey.statsDeleteRequests: 'DELETE requests:',
        NetworkTranslationKey.statsPutRequests: 'PUT requests:',
        NetworkTranslationKey.statsPatchRequests: 'PATCH requests:',
        NetworkTranslationKey.statsSecuredRequests: 'Secured requests:',
        NetworkTranslationKey.statsUnsecuredRequests: 'Unsecured requests:',
        NetworkTranslationKey.notificationLoading: 'Loading:',
        NetworkTranslationKey.notificationSuccess: 'Success:',
        NetworkTranslationKey.notificationRedirect: 'Redirect:',
        NetworkTranslationKey.notificationError: 'Error:',
        NetworkTranslationKey.notificationTotalRequests:
            'NetworkInspector (total [callCount] HTTP calls)',
        NetworkTranslationKey.saveDialogPermissionErrorTitle:
            'Permission error',
        NetworkTranslationKey.saveDialogPermissionErrorDescription:
            "Permission not granted. Couldn't save logs.",
        NetworkTranslationKey.saveDialogEmptyErrorTitle: 'Call history empty',
        NetworkTranslationKey.saveDialogEmptyErrorDescription:
            'There are no calls to save.',
        NetworkTranslationKey.saveDialogFileSaveErrorTitle: 'Save error',
        NetworkTranslationKey.saveDialogFileSaveErrorDescription:
            'Failed to save http calls to file.',
        NetworkTranslationKey.saveSuccessTitle: 'Logs saved',
        NetworkTranslationKey.saveSuccessDescription:
            'Successfully saved logs in [path].',
        NetworkTranslationKey.saveSuccessView: 'View file',
        NetworkTranslationKey.saveHeaderTitle:
            'NetworkInspector - HTTP Inspector',
        NetworkTranslationKey.saveHeaderAppName: 'App name:',
        NetworkTranslationKey.saveHeaderPackage: 'Package:',
        NetworkTranslationKey.saveHeaderVersion: 'Version:',
        NetworkTranslationKey.saveHeaderBuildNumber: 'Build number:',
        NetworkTranslationKey.saveHeaderGenerated: 'Generated:',
        NetworkTranslationKey.saveLogId: 'Id:',
        NetworkTranslationKey.saveLogGeneralData: 'General data',
        NetworkTranslationKey.saveLogServer: 'Server:',
        NetworkTranslationKey.saveLogMethod: 'Method:',
        NetworkTranslationKey.saveLogEndpoint: 'Endpoint:',
        NetworkTranslationKey.saveLogClient: 'Client:',
        NetworkTranslationKey.saveLogDuration: 'Duration:',
        NetworkTranslationKey.saveLogSecured: 'Secured connection:',
        NetworkTranslationKey.saveLogCompleted: 'Completed:',
        NetworkTranslationKey.saveLogRequest: 'Request',
        NetworkTranslationKey.saveLogRequestTime: 'Request time:',
        NetworkTranslationKey.saveLogRequestContentType:
            'Request content type:',
        NetworkTranslationKey.saveLogRequestCookies: 'Request cookies:',
        NetworkTranslationKey.saveLogRequestHeaders: 'Request headers:',
        NetworkTranslationKey.saveLogRequestQueryParams:
            'Request query params:',
        NetworkTranslationKey.saveLogRequestSize: 'Request size:',
        NetworkTranslationKey.saveLogRequestBody: 'Request body:',
        NetworkTranslationKey.saveLogResponse: 'Response',
        NetworkTranslationKey.saveLogResponseTime: 'Response time:',
        NetworkTranslationKey.saveLogResponseStatus: 'Response status:',
        NetworkTranslationKey.saveLogResponseSize: 'Response size:',
        NetworkTranslationKey.saveLogResponseHeaders: 'Response headers:',
        NetworkTranslationKey.saveLogResponseBody: 'Response body:',
        NetworkTranslationKey.saveLogError: 'Error',
        NetworkTranslationKey.saveLogStackTrace: 'Stack trace',
        NetworkTranslationKey.saveLogCurl: 'Curl',
        NetworkTranslationKey.accept: 'Accept',
        NetworkTranslationKey.parserFailed: 'Failed to parse: ',
        NetworkTranslationKey.unknown: 'Unknown',
      },
    );
  }

  /// Builds [NetworkTranslationData] for polish language.
  static NetworkTranslationData _buildPlTranslations() {
    return NetworkTranslationData(
      languageCode: 'pl',
      values: {
        NetworkTranslationKey.networkInspector: 'Network',
        NetworkTranslationKey.callDetails: 'Połączenie HTTP - detale',
        NetworkTranslationKey.emailSubject: 'Raport ALice',
        NetworkTranslationKey.callDetailsRequest: 'Żądanie',
        NetworkTranslationKey.callDetailsResponse: 'Odpowiedź',
        NetworkTranslationKey.callDetailsOverview: 'Przegląd',
        NetworkTranslationKey.callDetailsError: 'Błąd',
        NetworkTranslationKey.callDetailsEmpty: 'Błąd ładowania danych',
        NetworkTranslationKey.callErrorScreenErrorEmpty: 'Brak błędów',
        NetworkTranslationKey.callErrorScreenError: 'Błąd:',
        NetworkTranslationKey.callErrorScreenStacktrace: 'Ślad stosu:',
        NetworkTranslationKey.callErrorScreenEmpty:
            'Brak danych do wyświetlenia',
        NetworkTranslationKey.callOverviewMethod: 'Metoda:',
        NetworkTranslationKey.callOverviewServer: 'Serwer:',
        NetworkTranslationKey.callOverviewEndpoint: 'Endpoint:',
        NetworkTranslationKey.callOverviewStarted: 'Rozpoczęto:',
        NetworkTranslationKey.callOverviewFinished: 'Zakończono:',
        NetworkTranslationKey.callOverviewDuration: 'Czas trwania:',
        NetworkTranslationKey.callOverviewBytesSent: 'Bajty wysłane:',
        NetworkTranslationKey.callOverviewBytesReceived: 'Bajty odebrane:',
        NetworkTranslationKey.callOverviewClient: 'Klient:',
        NetworkTranslationKey.callOverviewSecure: 'Połączenie zabezpieczone:',
        NetworkTranslationKey.callRequestStarted: 'Ropoczęto:',
        NetworkTranslationKey.callRequestBytesSent: 'Bajty wysłane:',
        NetworkTranslationKey.callRequestContentType: 'Typ zawartości:',
        NetworkTranslationKey.callRequestBody: 'Body:',
        NetworkTranslationKey.callRequestBodyEmpty: 'Body jest puste',
        NetworkTranslationKey.callRequestFormDataFields: 'Pola forumlarza:',
        NetworkTranslationKey.callRequestFormDataFiles: 'Pliki formularza:',
        NetworkTranslationKey.callRequestHeaders: 'Headery:',
        NetworkTranslationKey.callRequestHeadersEmpty: 'Headery są puste',
        NetworkTranslationKey.callRequestQueryParameters: 'Parametry query',
        NetworkTranslationKey.callRequestQueryParametersEmpty:
            'Parametry query są puste',
        NetworkTranslationKey.callResponseWaitingForResponse:
            'Oczekiwanie na odpowiedź...',
        NetworkTranslationKey.callResponseError: 'Błąd',
        NetworkTranslationKey.callResponseReceived: 'Otrzymano:',
        NetworkTranslationKey.callResponseBytesReceived: 'Bajty odebrane:',
        NetworkTranslationKey.callResponseStatus: 'Status:',
        NetworkTranslationKey.callResponseHeaders: 'Headery:',
        NetworkTranslationKey.callResponseHeadersEmpty: 'Headery są puste',
        NetworkTranslationKey.callResponseBodyImage: 'Body: Obraz',
        NetworkTranslationKey.callResponseBody: 'Body:',
        NetworkTranslationKey.callResponseTooLargeToShow: 'Za duże aby pokazać',
        NetworkTranslationKey.callResponseBodyShow: 'Pokaż body',
        NetworkTranslationKey.callResponseLargeBodyShowWarning:
            'Uwaga! Może zająć trochę czasu, zanim uda się wyrenderować output.',
        NetworkTranslationKey.callResponseBodyVideo: 'Body: Video',
        NetworkTranslationKey.callResponseBodyVideoWebBrowser:
            'Otwórz video w przeglądarce',
        NetworkTranslationKey.callResponseHeadersUnknown: 'Nieznane',
        NetworkTranslationKey.callResponseBodyUnknown:
            'Nieznane body. Network'
            ' może renderować video/image/text. Odpowiedź ma typ zawartości:'
            '[contentType], który nie może być obsłużony.Jeżeli chcesz, możesz '
            'spróbować wyrenderować body jako tekst, ale może to się nie udać.',
        NetworkTranslationKey.callResponseBodyUnknownShow:
            'Pokaż nieobsługiwane body',
        NetworkTranslationKey.callsListInspector: 'Inspektor',
        NetworkTranslationKey.callsListLogger: 'Logger',
        NetworkTranslationKey.callsListDeleteLogsDialogTitle: 'Usuń logi',
        NetworkTranslationKey.callsListDeleteLogsDialogDescription:
            'Czy chcesz usunąc logi?',
        NetworkTranslationKey.callsListYes: 'Tak',
        NetworkTranslationKey.callsListNo: 'Nie',
        NetworkTranslationKey.callsListDeleteCallsDialogTitle:
            'Usuń połączenia',
        NetworkTranslationKey.callsListDeleteCallsDialogDescription:
            'Czy chcesz usunąć zapisane połaczenia HTTP?',
        NetworkTranslationKey.callsListSearchHint: 'Szukaj połączenia HTTP...',
        NetworkTranslationKey.callsListSort: 'Sortuj',
        NetworkTranslationKey.callsListDelete: 'Usuń',
        NetworkTranslationKey.callsListStats: 'Statystyki',
        NetworkTranslationKey.callsListSave: 'Zapis',
        NetworkTranslationKey.logsEmpty: 'Brak rezultatów',
        NetworkTranslationKey.logsError: 'Problem z wyświetleniem logów.',
        NetworkTranslationKey.logsItemError: 'Błąd:',
        NetworkTranslationKey.logsItemStackTrace: 'Ślad stosu:',
        NetworkTranslationKey.logsCopied: 'Skopiowano do schowka.',
        NetworkTranslationKey.sortDialogTitle: 'Wybierz filtr',
        NetworkTranslationKey.sortDialogAscending: 'Rosnąco',
        NetworkTranslationKey.sortDialogDescending: 'Malejąco',
        NetworkTranslationKey.sortDialogAccept: 'Akceptuj',
        NetworkTranslationKey.sortDialogCancel: 'Anuluj',
        NetworkTranslationKey.sortDialogTime: 'Czas utworzenia (domyślnie)',
        NetworkTranslationKey.sortDialogResponseTime: 'Czas odpowiedzi',
        NetworkTranslationKey.sortDialogResponseCode: 'Status odpowiedzi',
        NetworkTranslationKey.sortDialogResponseSize: 'Rozmiar odpowiedzi',
        NetworkTranslationKey.sortDialogEndpoint: 'Endpoint',
        NetworkTranslationKey.statsTitle: 'Statystyki',
        NetworkTranslationKey.statsTotalRequests: 'Razem żądań:',
        NetworkTranslationKey.statsPendingRequests: 'Oczekujące żądania:',
        NetworkTranslationKey.statsSuccessRequests: 'Poprawne żądania:',
        NetworkTranslationKey.statsRedirectionRequests:
            'Żądania przekierowania:',
        NetworkTranslationKey.statsErrorRequests: 'Błędne żądania:',
        NetworkTranslationKey.statsBytesSent: 'Bajty wysłane:',
        NetworkTranslationKey.statsBytesReceived: 'Bajty otrzymane:',
        NetworkTranslationKey.statsAverageRequestTime: 'Średni czas żądania:',
        NetworkTranslationKey.statsMaxRequestTime: 'Maksymalny czas żądania:',
        NetworkTranslationKey.statsMinRequestTime: 'Minimalny czas żądania:',
        NetworkTranslationKey.statsGetRequests: 'Żądania GET:',
        NetworkTranslationKey.statsPostRequests: 'Żądania POST:',
        NetworkTranslationKey.statsDeleteRequests: 'Żądania DELETE:',
        NetworkTranslationKey.statsPutRequests: 'Żądania PUT:',
        NetworkTranslationKey.statsPatchRequests: 'Żądania PATCH:',
        NetworkTranslationKey.statsSecuredRequests: 'Żądania zabezpieczone:',
        NetworkTranslationKey.statsUnsecuredRequests:
            'Żądania niezabezpieczone:',
        NetworkTranslationKey.notificationLoading: 'Oczekujące:',
        NetworkTranslationKey.notificationSuccess: 'Poprawne:',
        NetworkTranslationKey.notificationRedirect: 'Przekierowanie:',
        NetworkTranslationKey.notificationError: 'Błąd:',
        NetworkTranslationKey.notificationTotalRequests:
            'NetworkInspector (razem [callCount] połączeń HTTP)',
        NetworkTranslationKey.saveDialogPermissionErrorTitle: 'Błąd pozwolenia',
        NetworkTranslationKey.saveDialogPermissionErrorDescription:
            'Pozwolenie nieprzyznane. Nie można zapisać logów.',
        NetworkTranslationKey.saveDialogEmptyErrorTitle:
            'Pusta historia połaczeń',
        NetworkTranslationKey.saveDialogEmptyErrorDescription:
            'Nie ma połączeń do zapisania.',
        NetworkTranslationKey.saveDialogFileSaveErrorTitle: 'Błąd zapisu',
        NetworkTranslationKey.saveDialogFileSaveErrorDescription:
            'Nie można zapisać danych do pliku.',
        NetworkTranslationKey.saveSuccessTitle: 'Logi zapisane',
        NetworkTranslationKey.saveSuccessDescription: 'Zapisano logi w [path].',
        NetworkTranslationKey.saveSuccessView: 'Otwórz plik',
        NetworkTranslationKey.saveHeaderTitle:
            'NetworkInspector - Inspektor HTTP',
        NetworkTranslationKey.saveHeaderAppName: 'Nazwa aplikacji:',
        NetworkTranslationKey.saveHeaderPackage: 'Paczka:',
        NetworkTranslationKey.saveHeaderVersion: 'Wersja:',
        NetworkTranslationKey.saveHeaderBuildNumber: 'Numer buildu:',
        NetworkTranslationKey.saveHeaderGenerated: 'Wygenerowano:',
        NetworkTranslationKey.saveLogId: 'Id:',
        NetworkTranslationKey.saveLogGeneralData: 'Ogólne informacje',
        NetworkTranslationKey.saveLogServer: 'Serwer:',
        NetworkTranslationKey.saveLogMethod: 'Metoda:',
        NetworkTranslationKey.saveLogEndpoint: 'Endpoint:',
        NetworkTranslationKey.saveLogClient: 'Klient:',
        NetworkTranslationKey.saveLogDuration: 'Czas trwania:',
        NetworkTranslationKey.saveLogSecured: 'Połączenie zabezpieczone:',
        NetworkTranslationKey.saveLogCompleted: 'Zakończono:',
        NetworkTranslationKey.saveLogRequest: 'Żądanie',
        NetworkTranslationKey.saveLogRequestTime: 'Czas żądania:',
        NetworkTranslationKey.saveLogRequestContentType:
            'Typ zawartości żądania:',
        NetworkTranslationKey.saveLogRequestCookies: 'Ciasteczka żądania:',
        NetworkTranslationKey.saveLogRequestHeaders: 'Heady żądania',
        NetworkTranslationKey.saveLogRequestQueryParams:
            'Parametry query żądania',
        NetworkTranslationKey.saveLogRequestSize: 'Rozmiar żądania:',
        NetworkTranslationKey.saveLogRequestBody: 'Body żądania:',
        NetworkTranslationKey.saveLogResponse: 'Odpowiedź',
        NetworkTranslationKey.saveLogResponseTime: 'Czas odpowiedzi:',
        NetworkTranslationKey.saveLogResponseStatus: 'Status odpowiedzi:',
        NetworkTranslationKey.saveLogResponseSize: 'Rozmiar odpowiedzi:',
        NetworkTranslationKey.saveLogResponseHeaders: 'Headery odpowiedzi:',
        NetworkTranslationKey.saveLogResponseBody: 'Body odpowiedzi:',
        NetworkTranslationKey.saveLogError: 'Błąd',
        NetworkTranslationKey.saveLogStackTrace: 'Ślad stosu',
        NetworkTranslationKey.saveLogCurl: 'Curl',
        NetworkTranslationKey.accept: 'Akceptuj',
        NetworkTranslationKey.parserFailed: 'Problem z parsowaniem: ',
        NetworkTranslationKey.unknown: 'Nieznane',
      },
    );
  }

  /// Returns localized value for specific [languageCode] and [key]. If value
  /// can't be selected then [key] will be returned.
  static String get({
    required String languageCode,
    required NetworkTranslationKey key,
  }) {
    try {
      final data = _translations.firstWhere(
        (element) => element.languageCode == languageCode,
        orElse: () => _translations.first,
      );
      final value = data.values[key] ?? key.toString();
      return value;
    } catch (error) {
      return key.toString();
    }
  }
}
