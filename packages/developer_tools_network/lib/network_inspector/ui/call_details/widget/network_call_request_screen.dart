import 'package:developer_tools_network/network_inspector/helper/network_conversion_helper.dart';
import 'package:developer_tools_network/network_inspector/helper/network_postman_export_helper.dart';
import 'package:developer_tools_network/network_inspector/model/network_form_data_file.dart';
import 'package:developer_tools_network/network_inspector/model/network_from_data_field.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'package:developer_tools_network/network_inspector/model/network_translation.dart';
import 'package:developer_tools_network/network_inspector/ui/call_details/widget/network_call_list_row.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_context_ext.dart';
import 'package:developer_tools_network/network_inspector/utils/network_parser.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_scroll_behavior.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Screen which displays information about call request: content, transfer,
/// headers.
class NetworkCallRequestScreen extends StatelessWidget {
  final NetworkHttpCall call;

  const NetworkCallRequestScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [
      NetworkCallListRow(
        name: context.i18n(NetworkTranslationKey.callRequestStarted),
        value: call.request?.time.toString(),
      ),
      NetworkCallListRow(
        name: context.i18n(NetworkTranslationKey.callRequestBytesSent),
        value: NetworkConversionHelper.formatBytes(call.request?.size ?? 0),
      ),
      NetworkCallListRow(
        name: context.i18n(NetworkTranslationKey.callRequestContentType),
        value: NetworkParser.getContentType(
          context: context,
          headers: call.request?.headers,
        ),
      ),
    ];

    // The uploads and the base64 media in the bodies, as the export shares them.
    final List<NetworkExportAttachment> attachments =
        NetworkPostmanExportHelper.buildAttachments([call]);
    if (attachments.isNotEmpty) {
      rows.add(const NetworkCallListRow(name: 'Files', value: ''));
      rows.addAll([
        for (final NetworkExportAttachment file in attachments)
          _AttachmentPreview(file: file),
      ]);
    }

    rows.add(
      NetworkCallListRow(
        name: context.i18n(NetworkTranslationKey.callRequestBody),
        value: _getBodyContent(context: context),
      ),
    );

    final List<NetworkFormDataField>? formDataFields =
        call.request?.formDataFields;
    if (formDataFields?.isNotEmpty ?? false) {
      rows.add(
        NetworkCallListRow(
          name: context.i18n(NetworkTranslationKey.callRequestFormDataFields),
          value: '',
        ),
      );
      rows.addAll([
        for (final NetworkFormDataField field in formDataFields!)
          NetworkCallListRow(name: '   • ${field.name}:', value: field.value),
      ]);
    }

    final List<NetworkFormDataFile>? formDataFiles =
        call.request!.formDataFiles;
    if (formDataFiles?.isNotEmpty ?? false) {
      rows.add(
        NetworkCallListRow(
          name: context.i18n(NetworkTranslationKey.callRequestFormDataFiles),
          value: '',
        ),
      );
      rows.addAll([
        for (final NetworkFormDataFile file in formDataFiles!)
          NetworkCallListRow(
            name: '   • ${file.fileName}:',
            value: '${file.contentType} / ${file.length} B',
          ),
      ]);
    }

    final Map<String, dynamic>? headers = call.request?.headers;
    final String headersContent = headers?.isEmpty ?? true
        ? context.i18n(NetworkTranslationKey.callRequestHeadersEmpty)
        : '';
    rows.add(
      NetworkCallListRow(
        name: context.i18n(NetworkTranslationKey.callRequestHeaders),
        value: headersContent,
      ),
    );
    rows.addAll([
      for (final MapEntry<String, dynamic> header in headers?.entries ?? [])
        NetworkCallListRow(
          name: '   • ${header.key}:',
          value: header.value.toString(),
        ),
    ]);

    final Map<String, dynamic>? queryParameters = call.request?.queryParameters;
    final String queryParametersContent = queryParameters?.isEmpty ?? true
        ? context.i18n(
            NetworkTranslationKey.callRequestQueryParametersEmpty,
          )
        : '';
    rows.add(
      NetworkCallListRow(
        name: context.i18n(NetworkTranslationKey.callRequestQueryParameters),
        value: queryParametersContent,
      ),
    );
    rows.addAll([
      for (final MapEntry<String, dynamic> queryParam
          in queryParameters?.entries ?? [])
        NetworkCallListRow(
          name: '   • ${queryParam.key}:',
          value: queryParam.value.toString(),
        ),
    ]);

    return Container(
      padding: const EdgeInsets.all(6),
      child: ScrollConfiguration(
        behavior: NetworkScrollBehavior(),
        child: ListView(children: rows),
      ),
    );
  }

  /// Returns body content formatted.
  String _getBodyContent({required BuildContext context}) {
    final dynamic body = NetworkPostmanExportHelper.labelBase64Media(
      call.request?.body,
    );
    return body != null
        ? NetworkParser.formatBody(
            context: context,
            body: body,
            contentType: NetworkParser.getContentType(
              context: context,
              headers: call.request?.headers,
            ),
          )
        : context.i18n(NetworkTranslationKey.callRequestBodyEmpty);
  }
}

/// One exported file: its name and size, and the picture when it is an image.
class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({required this.file});

  final NetworkExportAttachment file;

  static const Set<String> _images = {'jpg', 'png', 'gif'};

  @override
  Widget build(BuildContext context) {
    final String ext = file.name.split('.').last.toLowerCase();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '   • ${file.name} (${NetworkConversionHelper.formatBytes(file.bytes.length)})',
          ),
          if (_images.contains(ext))
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Image.memory(
                file.bytes,
                key: ValueKey(file.name),
                height: 140,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
            ),
        ],
      ),
    );
  }
}
