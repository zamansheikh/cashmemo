import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/cash_memo.dart';
import '../../domain/entities/shop_settings.dart';
import '../constants/app_constants.dart';

class PdfService {
  // Colors
  static final PdfColor _yellowColor = PdfColor(255, 193, 7); // Amber
  static final PdfColor _darkColor = PdfColor(51, 51, 51); // Dark Grey
  static final PdfColor _lightGrayColor = PdfColor(245, 245, 245);
  // static final PdfColor _borderColor = PdfColor(220, 220, 220);
  static final PdfColor _textColor = PdfColor(60, 60, 60);
  static final PdfColor _whiteColor = PdfColor(255, 255, 255);

  static Future<void> generateAndPrintCashMemo(
    CashMemo cashMemo,
    ShopSettings shopSettings,
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
      style: PdfFontStyle.regular,
    );
    final PdfFont boldFont = PdfTrueTypeFont(
      boldFontData.buffer.asUint8List(),
      10,
      style: PdfFontStyle.bold,
    );
    final PdfFont titleFont = PdfTrueTypeFont(
      boldFontData.buffer.asUint8List(),
      24,
      style: PdfFontStyle.bold,
    );
    final PdfFont headerFont = PdfTrueTypeFont(
      boldFontData.buffer.asUint8List(),
      30,
      style: PdfFontStyle.bold,
    );
    final PdfFont mediumFont = PdfTrueTypeFont(
      boldFontData.buffer.asUint8List(),
      14,
      style: PdfFontStyle.bold,
    );

    final PdfPage page = document.pages.add();
    final PdfGraphics graphics = page.graphics;
    final double pageWidth = page.getClientSize().width;
    final double pageHeight = page.getClientSize().height;
    final double margin = 40;

    double yPosition = 30;

    // 1. Header
    yPosition = _drawHeader(
      graphics,
      shopSettings,
      titleFont,
      regularFont,
      headerFont,
      pageWidth,
      yPosition,
      margin,
      shopSettings,
    );

    // 2. Invoice Info
    yPosition = _drawInvoiceInfo(
      graphics,
      cashMemo,
      mediumFont,
      boldFont,
      regularFont,
      yPosition,
      pageWidth,
      margin,
    );

    // 3. Items Table
    final PdfLayoutResult tableResult = _drawItemsTable(
      page,
      cashMemo,
      boldFont,
      regularFont,
      yPosition + 20,
      pageWidth,
      margin,
    );
    yPosition = tableResult.bounds.bottom + 20;

    // 4. Footer Section (Summary, Terms, Sign)
    _drawFooterSection(
      graphics,
      cashMemo,
      shopSettings,
      mediumFont,
      regularFont,
      boldFont,
      regularFont, // smallFont (using regular for now)
      yPosition,
      pageWidth,
      pageHeight,
      margin,
    );

    // 5. Bottom Bar
    _drawBottomBar(graphics, pageWidth, pageHeight, margin, regularFont);

    // Save and Print
    final List<int> bytes = await document.save();
    document.dispose();

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => Uint8List.fromList(bytes),
    );
  }

  static double _drawHeader(
    PdfGraphics graphics,
    ShopSettings settings,
    PdfFont titleFont,
    PdfFont taglineFont,
    PdfFont headerFont,
    double pageWidth,
    double yPosition,
    double margin,
    ShopSettings shopSettings,
  ) {
    // Logo (Diamond Shape)
    final double logoSize = 30;
    final double logoX = margin;
    final double logoY = yPosition;

    graphics.drawPolygon([
      Offset(logoX + logoSize / 2, logoY), // Top
      Offset(logoX + logoSize, logoY + logoSize / 2), // Right
      Offset(logoX + logoSize / 2, logoY + logoSize), // Bottom
      Offset(logoX, logoY + logoSize / 2), // Left
    ], pen: PdfPen(_darkColor, width: 3));

    // Brand Name & Tagline
    final String shopName = shopSettings.shopName;
    final String tagline = shopSettings.tagline ?? 'TAGLINE SPACE HERE';
    final double textX = margin + logoSize + 15;

    graphics.drawString(
      shopName,
      titleFont,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(textX, yPosition, 300, 30),
    );

    graphics.drawString(
      tagline,
      taglineFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(textX, yPosition + 30, 300, 15),
    );

    // INVOICE Text on Right
    final Size invoiceSize = headerFont.measureString('INVOICE');
    graphics.drawString(
      'INVOICE',
      headerFont,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(
        pageWidth - margin - invoiceSize.width - 60,
        yPosition + 40,
        invoiceSize.width,
        invoiceSize.height,
      ),
    );

    // Yellow Bar
    double barY = yPosition + 50;

    // Left part of yellow bar
    graphics.drawRectangle(
      brush: PdfSolidBrush(_yellowColor),
      bounds: Rect.fromLTWH(0, barY, pageWidth * 0.55, 25),
    );

    // Right part of yellow bar
    graphics.drawRectangle(
      brush: PdfSolidBrush(_yellowColor),
      bounds: Rect.fromLTWH(pageWidth * 0.85, barY, pageWidth * 0.15, 25),
    );

    return barY + 40;
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
      brush: PdfSolidBrush(_darkColor),
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

    // Right: Invoice Details
    double rightY = yPosition + 5;
    final double rightColX = pageWidth - margin - 250;

    // Invoice #
    graphics.drawString(
      'Invoice#',
      boldFont,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(rightColX, rightY, 80, 15),
    );
    graphics.drawString(
      cashMemo.memoNumber,
      boldFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(rightColX + 100, rightY, 150, 15),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
    rightY += 20;

    // Date
    graphics.drawString(
      'Date',
      boldFont,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(rightColX, rightY, 80, 15),
    );
    graphics.drawString(
      DateFormat('dd / MM / yyyy').format(cashMemo.date),
      boldFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(rightColX + 100, rightY, 150, 15),
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
        textBrush: PdfSolidBrush(_whiteColor),
        backgroundBrush: PdfSolidBrush(_darkColor),
        cellPadding: PdfPaddings(left: 5, right: 5, top: 10, bottom: 10),
        borders: PdfBorders(
          left: PdfPen(_darkColor, width: 0),
          right: PdfPen(_darkColor, width: 0),
          top: PdfPen(_darkColor, width: 0),
          bottom: PdfPen(_darkColor, width: 0),
        ),
      );
      if (i >= 2) {
        headerRow.cells[i].stringFormat = PdfStringFormat(
          alignment: PdfTextAlignment.right,
          lineAlignment: PdfVerticalAlignment.middle,
        );
      } else {
        headerRow.cells[i].stringFormat = PdfStringFormat(
          alignment: PdfTextAlignment.left,
          lineAlignment: PdfVerticalAlignment.middle,
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

      final PdfColor rowColor = (i % 2 == 0) ? _whiteColor : _lightGrayColor;

      for (int j = 0; j < 5; j++) {
        row.cells[j].style = PdfGridCellStyle(
          font: regularFont,
          textBrush: PdfSolidBrush(_textColor),
          backgroundBrush: PdfSolidBrush(rowColor),
          cellPadding: PdfPaddings(left: 5, right: 5, top: 10, bottom: 10),
          borders: PdfBorders(
            left: PdfPen(rowColor, width: 0),
            right: PdfPen(rowColor, width: 0),
            top: PdfPen(rowColor, width: 0),
            bottom: PdfPen(rowColor, width: 0),
          ),
        );
        if (j >= 2) {
          row.cells[j].stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
          );
        } else {
          row.cells[j].stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.left,
            lineAlignment: PdfVerticalAlignment.middle,
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

    // Draw border around the empty space below?
    // The image shows a box around the items area, extending down.
    // Since we can't easily draw a box that expands, let's just draw a border around the table if needed.
    // But the image shows the table header is dark, rows are alternating.
    // And there is a border around the whole "content" area?
    // Actually, looking at the image, there is a thin blue border around the white space below the items?
    // Let's skip the complex dynamic border for now and focus on the table style.

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
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(margin, yPosition, 300, 20),
    );
    yPosition += 30;

    double leftY = yPosition;
    double rightY = yPosition;

    // 2. Left Side: Payment Info & Terms
    // Terms & Conditions
    graphics.drawString(
      'Terms & Conditions',
      boldFont,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(margin, leftY, 200, 15),
    );
    leftY += 15;
    graphics.drawString(
      'Lorem ipsum dolor sit amet, consectetur adipiscing\nelit. Fusce dignissim pretium consectetur.',
      regularFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(margin, leftY, 300, 40),
    );
    leftY += 40;

    // Payment Info
    graphics.drawString(
      'Payment Info:',
      boldFont,
      brush: PdfSolidBrush(_darkColor),
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

    // 3. Right Side: Totals
    final double rightColX = pageWidth - margin - 250;
    final double rightColWidth = 250;

    // Sub Total
    _drawTotalRow(
      graphics,
      'Sub Total:',
      cashMemo.subtotal,
      boldFont,
      rightColX,
      rightY,
      rightColWidth,
    );
    rightY += 25;

    // Tax
    _drawTotalRow(
      graphics,
      'Tax:',
      cashMemo.tax,
      boldFont,
      rightColX,
      rightY,
      rightColWidth,
    );
    rightY += 25;

    // Total Box (Yellow)
    graphics.drawRectangle(
      brush: PdfSolidBrush(_yellowColor),
      bounds: Rect.fromLTWH(rightColX, rightY, rightColWidth, 35),
    );

    graphics.drawString(
      'Total:',
      mediumFont,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(rightColX + 10, rightY + 8, 100, 20),
    );
    graphics.drawString(
      '${AppConstants.currencySymbol}${cashMemo.total.toStringAsFixed(2)}',
      mediumFont,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(rightColX + 100, rightY + 8, 140, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
  }

  static void _drawBottomBar(
    PdfGraphics graphics,
    double pageWidth,
    double pageHeight,
    double margin,
    PdfFont font,
  ) {
    // Yellow Bar at bottom
    graphics.drawRectangle(
      brush: PdfSolidBrush(_yellowColor),
      bounds: Rect.fromLTWH(0, pageHeight - 40, pageWidth * 0.6, 5),
    );
    graphics.drawRectangle(
      brush: PdfSolidBrush(_yellowColor),
      bounds: Rect.fromLTWH(
        pageWidth * 0.9,
        pageHeight - 40,
        pageWidth * 0.1,
        5,
      ),
    );

    // Contact Info
    final String contactInfo = 'Phone #   |   Address   |   Website';
    graphics.drawString(
      contactInfo,
      font,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(margin + 20, pageHeight - 25, 400, 20),
    );

    // Authorised Sign
    final double signY = pageHeight - 60;
    final double signX = pageWidth - margin - 150;
    graphics.drawLine(
      PdfPen(_darkColor, width: 1),
      Offset(signX, signY),
      Offset(signX + 150, signY),
    );
    graphics.drawString(
      'Authorised Sign',
      font,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(signX, signY + 5, 150, 15),
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
      brush: PdfSolidBrush(_darkColor),
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
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(x, y, width / 2, 15),
    );
    graphics.drawString(
      '${AppConstants.currencySymbol}${value.toStringAsFixed(2)}',
      font,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(x + width / 2, y, width / 2, 15),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
  }
}
