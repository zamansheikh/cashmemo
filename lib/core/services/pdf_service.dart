import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/cash_memo.dart';
import '../../domain/entities/shop_settings.dart';
import '../constants/app_constants.dart';

class PdfService {
  // Colors
  static final PdfColor _orangeColor = PdfColor(255, 87, 34);
  static final PdfColor _darkBlueColor = PdfColor(26, 46, 77);
  static final PdfColor _textColor = PdfColor(60, 60, 60);

  static Future<void> generateAndPrintCashMemo(
    CashMemo cashMemo,
    ShopSettings? shopSettings,
  ) async {
    // Create PDF document
    final PdfDocument document = PdfDocument();
    document.pageSettings.size = PdfPageSize.a4;
    document.pageSettings.margins.all = 0;

    // Load fonts
    final ByteData regularFontData = await rootBundle.load(
      'assets/Noto_Serif_Bengali/static/NotoSerifBengali-Regular.ttf',
    );
    final ByteData boldFontData = await rootBundle.load(
      'assets/Noto_Serif_Bengali/static/NotoSerifBengali-Bold.ttf',
    );

    final PdfFont regularFont = PdfTrueTypeFont(
      regularFontData.buffer.asUint8List(),
      10,
    );
    final PdfFont boldFont = PdfTrueTypeFont(
      boldFontData.buffer.asUint8List(),
      10,
    );
    final PdfFont mediumFont = PdfTrueTypeFont(
      boldFontData.buffer.asUint8List(),
      12,
    );
    final PdfFont headerFont = PdfTrueTypeFont(
      boldFontData.buffer.asUint8List(),
      30,
    );
    final PdfFont titleFont = PdfTrueTypeFont(
      boldFontData.buffer.asUint8List(),
      18,
    );
    final PdfFont smallFont = PdfTrueTypeFont(
      regularFontData.buffer.asUint8List(),
      8,
    );

    // Initial Page
    PdfPage currentPage = document.pages.add();
    final double pageWidth = currentPage.getClientSize().width;
    final double pageHeight = currentPage.getClientSize().height;
    final double margin = 40;
    double yPosition = 0;

    // Draw Header (Geometric Shapes)
    yPosition = _drawHeader(
      currentPage.graphics,
      shopSettings,
      headerFont,
      titleFont,
      regularFont,
      pageWidth,
    );

    yPosition += 30;

    // Draw Invoice Info (Customer & Invoice Details)
    yPosition = _drawInvoiceInfo(
      currentPage.graphics,
      cashMemo,
      titleFont,
      boldFont,
      regularFont,
      yPosition,
      pageWidth,
      margin,
    );

    yPosition += 30;

    // Draw Items Table
    final PdfLayoutResult result = _drawItemsTable(
      currentPage,
      cashMemo,
      boldFont,
      regularFont,
      yPosition,
      pageWidth,
      margin,
    );

    currentPage = result.page;
    yPosition = result.bounds.bottom + 30;

    // Draw Footer Section (Totals, Payment Info, Terms, Sign)
    // Check if we need a new page
    if (yPosition + 250 > pageHeight) {
      currentPage = document.pages.add();
      yPosition = margin + 50; // Add some top margin on new page
    }

    _drawFooterSection(
      currentPage.graphics,
      cashMemo,
      shopSettings,
      mediumFont,
      regularFont,
      boldFont,
      smallFont,
      yPosition,
      pageWidth,
      pageHeight,
      margin,
    );

    // Draw Geometric Footer on the last page
    _drawGeometricFooter(currentPage.graphics, pageWidth, pageHeight);

    // Save and print
    final List<int> bytes = await document.save();
    document.dispose();

    await Printing.layoutPdf(
      onLayout: (format) async => Uint8List.fromList(bytes),
    );
  }

  static double _drawHeader(
    PdfGraphics graphics,
    ShopSettings? settings,
    PdfFont headerFont,
    PdfFont titleFont,
    PdfFont regularFont,
    double pageWidth,
  ) {
    // 1. Dark Blue Shape (Left)
    graphics.drawPolygon([
      Offset(0, 0),
      Offset(pageWidth * 0.45, 0),
      Offset(pageWidth * 0.40, 80),
      Offset(0, 80),
    ], brush: PdfSolidBrush(_darkBlueColor));

    // 2. Orange Shape (Right)
    graphics.drawPolygon([
      Offset(pageWidth * 0.48, 0),
      Offset(pageWidth, 0),
      Offset(pageWidth, 100),
      Offset(pageWidth * 0.42, 100),
    ], brush: PdfSolidBrush(_orangeColor));

    // 3. INVOICE Text (Left)
    graphics.drawString(
      'INVOICE',
      headerFont,
      brush: PdfSolidBrush(_darkBlueColor),
      bounds: Rect.fromLTWH(40, 100, 200, 40),
    );

    // 4. Brand Name & Tagline (Right - inside Orange shape)
    final String shopName = settings?.shopName ?? 'Brand Name';
    final Size shopNameSize = titleFont.measureString(shopName);

    graphics.drawString(
      shopName,
      titleFont,
      brush: PdfSolidBrush(PdfColor(255, 255, 255)),
      bounds: Rect.fromLTWH(
        pageWidth - 40 - shopNameSize.width,
        30,
        shopNameSize.width,
        shopNameSize.height,
      ),
    );

    final String tagline = 'TAGLINE SPACE HERE'; // Placeholder or from settings
    final Size taglineSize = regularFont.measureString(tagline);
    graphics.drawString(
      tagline,
      regularFont,
      brush: PdfSolidBrush(PdfColor(255, 255, 255)),
      bounds: Rect.fromLTWH(
        pageWidth - 40 - taglineSize.width,
        30 + shopNameSize.height + 5,
        taglineSize.width,
        taglineSize.height,
      ),
    );

    return 150; // Return Y position below header
  }

  static double _drawInvoiceInfo(
    PdfGraphics graphics,
    CashMemo cashMemo,
    PdfFont titleFont,
    PdfFont boldFont,
    PdfFont regularFont,
    double yPosition,
    double pageWidth,
    double margin,
  ) {
    // Left: Invoice To
    graphics.drawString(
      'Invoice to:',
      titleFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(margin, yPosition, 200, 20),
    );

    double leftY = yPosition + 25;

    if (cashMemo.customerName != null) {
      graphics.drawString(
        cashMemo.customerName!,
        boldFont,
        brush: PdfSolidBrush(_textColor),
        bounds: Rect.fromLTWH(margin, leftY, 250, 15),
      );
      leftY += 15;
    }

    if (cashMemo.customerAddress != null &&
        cashMemo.customerAddress!.isNotEmpty) {
      graphics.drawString(
        cashMemo.customerAddress!,
        regularFont,
        brush: PdfSolidBrush(_textColor),
        bounds: Rect.fromLTWH(margin, leftY, 250, 40), // Multiline
      );
      leftY += 30;
    }

    if (cashMemo.customerPhone != null && cashMemo.customerPhone!.isNotEmpty) {
      graphics.drawString(
        cashMemo.customerPhone!,
        regularFont,
        brush: PdfSolidBrush(_textColor),
        bounds: Rect.fromLTWH(margin, leftY, 250, 15),
      );
    }

    // Right: Invoice Details
    double rightY = yPosition + 10;
    final double rightColX = pageWidth - margin - 200;

    // Invoice #
    graphics.drawString(
      'Invoice#',
      boldFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(rightColX, rightY, 80, 15),
    );
    graphics.drawString(
      cashMemo.memoNumber,
      boldFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(rightColX + 100, rightY, 100, 15),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
    rightY += 20;

    // Date
    graphics.drawString(
      'Date',
      boldFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(rightColX, rightY, 80, 15),
    );
    graphics.drawString(
      DateFormat('dd / MM / yyyy').format(cashMemo.date),
      boldFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(rightColX + 100, rightY, 100, 15),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );

    return leftY > rightY ? leftY : rightY;
  }

  static PdfLayoutResult _drawItemsTable(
    PdfPage page,
    CashMemo cashMemo,
    PdfFont boldFont,
    PdfFont regularFont,
    double yPosition,
    double pageWidth,
    double margin,
  ) {
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);

    final double tableWidth = pageWidth - (margin * 2);
    grid.columns[0].width = tableWidth * 0.08; // SL.
    grid.columns[1].width = tableWidth * 0.42; // Item Description
    grid.columns[2].width = tableWidth * 0.15; // Price
    grid.columns[3].width = tableWidth * 0.15; // Qty.
    grid.columns[4].width = tableWidth * 0.20; // Total

    final PdfGridRow headerRow = grid.headers.add(1)[0];
    headerRow.cells[0].value = 'SL.';
    headerRow.cells[1].value = 'Item Description';
    headerRow.cells[2].value = 'Price';
    headerRow.cells[3].value = 'Qty.';
    headerRow.cells[4].value = 'Total';

    // Header Style
    for (int i = 0; i < 5; i++) {
      headerRow.cells[i].style = PdfGridCellStyle(
        font: boldFont,
        textBrush: PdfSolidBrush(_textColor),
        backgroundBrush: PdfSolidBrush(PdfColor(255, 255, 255)),
        cellPadding: PdfPaddings(left: 5, right: 5, top: 10, bottom: 10),
        borders: PdfBorders(
          top: PdfPen(_orangeColor, width: 1.5),
          bottom: PdfPen(_orangeColor, width: 1.5),
          left: PdfPen(PdfColor(0, 0, 0, 0)),
          right: PdfPen(PdfColor(0, 0, 0, 0)),
        ),
      );
      if (i >= 2) {
        headerRow.cells[i].stringFormat = PdfStringFormat(
          alignment: PdfTextAlignment.right,
        );
      }
    }

    // Rows
    for (int i = 0; i < cashMemo.items.length; i++) {
      final item = cashMemo.items[i];
      final PdfGridRow row = grid.rows.add();

      row.cells[0].value = '${i + 1}';
      row.cells[1].value = item.productName;
      row.cells[2].value =
          '${AppConstants.currencySymbol}${item.price.toStringAsFixed(2)}';
      row.cells[3].value = '${item.quantity}';
      row.cells[4].value =
          '${AppConstants.currencySymbol}${item.total.toStringAsFixed(2)}';

      for (int j = 0; j < 5; j++) {
        row.cells[j].style = PdfGridCellStyle(
          font: regularFont,
          textBrush: PdfSolidBrush(_textColor),
          cellPadding: PdfPaddings(left: 5, right: 5, top: 10, bottom: 10),
          borders: PdfBorders(
            bottom: PdfPen(PdfColor(230, 230, 230), width: 1),
            left: PdfPen(PdfColor(0, 0, 0, 0)),
            right: PdfPen(PdfColor(0, 0, 0, 0)),
            top: PdfPen(PdfColor(0, 0, 0, 0)),
          ),
        );
        if (j >= 2) {
          row.cells[j].stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.right,
          );
        }
      }
    }

    grid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
      borderOverlapStyle: PdfBorderOverlapStyle.inside,
      font: regularFont,
    );

    final PdfLayoutResult result = grid.draw(
      page: page,
      bounds: Rect.fromLTWH(margin, yPosition, tableWidth, 0),
    )!;

    return result;
  }

  static void _drawFooterSection(
    PdfGraphics graphics,
    CashMemo cashMemo,
    ShopSettings? settings,
    PdfFont mediumFont,
    PdfFont regularFont,
    PdfFont boldFont,
    PdfFont smallFont,
    double yPosition,
    double pageWidth,
    double pageHeight,
    double margin,
  ) {
    // 1. Thank you message
    graphics.drawString(
      'Thank you for your business',
      boldFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(margin, yPosition, 300, 20),
    );
    yPosition += 30;

    double leftY = yPosition;
    double rightY = yPosition;

    // 2. Left Side: Payment Info & Terms
    // Payment Info
    graphics.drawString(
      'Payment Info:',
      boldFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(margin, leftY, 200, 15),
    );
    leftY += 20;

    final double labelWidth = 70;
    _drawLabelValue(
      graphics,
      'Account #:',
      '1234 5678 9012',
      regularFont,
      margin,
      leftY,
      labelWidth,
    );
    leftY += 15;
    _drawLabelValue(
      graphics,
      'A/C Name:',
      settings?.shopName ?? 'Shop Name',
      regularFont,
      margin,
      leftY,
      labelWidth,
    );
    leftY += 15;
    _drawLabelValue(
      graphics,
      'Bank Details:',
      'Add your bank details',
      regularFont,
      margin,
      leftY,
      labelWidth,
    );
    leftY += 30;

    // Terms & Conditions
    graphics.drawString(
      'Terms & Conditions',
      boldFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(margin, leftY, 200, 15),
    );
    leftY += 15;
    graphics.drawString(
      'Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit. Fusce\ndignissim pretium consectetur.',
      smallFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(margin, leftY, 250, 40),
    );

    // 3. Right Side: Totals
    final double rightColX = pageWidth - margin - 250;
    final double rightColWidth = 250;

    // Sub Total
    _drawTotalRow(
      graphics,
      'Sub Total:',
      cashMemo.subtotal,
      regularFont,
      rightColX,
      rightY,
      rightColWidth,
    );
    rightY += 20;

    // Tax
    _drawTotalRow(
      graphics,
      'Tax:',
      cashMemo.tax,
      regularFont,
      rightColX,
      rightY,
      rightColWidth,
    );
    rightY += 20;

    // Divider
    graphics.drawLine(
      PdfPen(PdfColor(200, 200, 200), width: 1),
      Offset(rightColX, rightY),
      Offset(rightColX + rightColWidth, rightY),
    );
    rightY += 10;

    // Total
    graphics.drawString(
      'Total:',
      mediumFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(rightColX, rightY, 100, 20),
    );
    graphics.drawString(
      '${AppConstants.currencySymbol}${cashMemo.total.toStringAsFixed(2)}',
      mediumFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(rightColX + 100, rightY, 150, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );

    // Authorised Sign
    final double signY = pageHeight - 120; // Position near bottom
    graphics.drawLine(
      PdfPen(_textColor, width: 1),
      Offset(pageWidth - margin - 150, signY),
      Offset(pageWidth - margin, signY),
    );
    graphics.drawString(
      'Authorised Sign',
      boldFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(pageWidth - margin - 150, signY + 5, 150, 15),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
  }

  static void _drawLabelValue(
    PdfGraphics graphics,
    String label,
    String value,
    PdfFont font,
    double x,
    double y,
    double labelWidth,
  ) {
    graphics.drawString(
      label,
      font,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(x, y, labelWidth, 15),
    );
    graphics.drawString(
      value,
      font,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(x + labelWidth + 10, y, 200, 15),
    );
  }

  static void _drawTotalRow(
    PdfGraphics graphics,
    String label,
    double value,
    PdfFont font,
    double x,
    double y,
    double width,
  ) {
    graphics.drawString(
      label,
      font,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(x, y, width / 2, 15),
    );
    graphics.drawString(
      '${AppConstants.currencySymbol}${value.toStringAsFixed(2)}',
      font,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(x + width / 2, y, width / 2, 15),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
  }

  static void _drawGeometricFooter(
    PdfGraphics graphics,
    double pageWidth,
    double pageHeight,
  ) {
    // 1. Dark Blue Shape (Left Bottom)
    graphics.drawPolygon(
      [
        Offset(0, pageHeight),
        Offset(0, pageHeight - 40),
        Offset(pageWidth * 0.35, pageHeight - 40),
        Offset(pageWidth * 0.45, pageHeight),
      ],
      brush: PdfSolidBrush(_darkBlueColor),
    );

    // 2. Orange Shape (Right Bottom)
    graphics.drawPolygon(
      [
        Offset(pageWidth * 0.50, pageHeight),
        Offset(pageWidth * 0.55, pageHeight - 50),
        Offset(pageWidth, pageHeight - 50),
        Offset(pageWidth, pageHeight),
      ],
      brush: PdfSolidBrush(_orangeColor),
    );
  }
}
