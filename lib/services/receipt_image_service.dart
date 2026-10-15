import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ReceiptImageService {
  Future<String> cacheReceipt(String sourcePath) async {
    final root = await getApplicationDocumentsDirectory();
    final folder = Directory(join(root.path, 'receipts'));
    if (!await folder.exists()) await folder.create(recursive: true);
    final suffix = extension(sourcePath).isEmpty ? '.jpg' : extension(sourcePath);
    final target = join(folder.path, 'receipt_${DateTime.now().millisecondsSinceEpoch}$suffix');
    return (await File(sourcePath).copy(target)).path;
  }
}
