import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
// Update these imports to match your project structure
import '../../domain/entities/cash_memo.dart';
import '../../domain/entities/shop_settings.dart';
import '../constants/app_constants.dart';

class PdfService {
  // Colors
  static final PdfColor _yellowColor = PdfColor(255, 193, 7);
  static final PdfColor _darkColor = PdfColor(51, 51, 51);
  static final PdfColor _lightGrayColor = PdfColor(245, 245, 245);
  static final PdfColor _textColor = PdfColor(60, 60, 60);
  static final PdfColor _whiteColor = PdfColor(255, 255, 255);

  static Future<void> generateAndPrintCashMemo(
    CashMemo cashMemo,
    ShopSettings shopSettings,
  ) async {
    final PdfDocument document = PdfDocument();
    document.pageSettings.size = PdfPageSize.a4;
    document.pageSettings.margins.all = 0;

    // Load fonts
    final ByteData regularData = await rootBundle.load(
      'assets/Noto_Serif_Bengali/static/NotoSerifBengali-Regular.ttf',
    );
    final ByteData boldData = await rootBundle.load(
      'assets/Noto_Serif_Bengali/static/NotoSerifBengali-Bold.ttf',
    );

    final PdfFont regularFont = PdfTrueTypeFont(
      regularData.buffer.asUint8List(),
      10,
    );
    final PdfFont boldFont = PdfTrueTypeFont(
      boldData.buffer.asUint8List(),
      10,
      style: PdfFontStyle.bold,
    );
    // Title Font for Shop Name
    final PdfFont titleFont = PdfTrueTypeFont(
      boldData.buffer.asUint8List(),
      24,
      style: PdfFontStyle.bold,
    );
    final PdfFont mediumFont = PdfTrueTypeFont(
      boldData.buffer.asUint8List(),
      14,
      style: PdfFontStyle.bold,
    );

    // Create the page
    final PdfPage page = document.pages.add();
    final PdfGraphics g = page.graphics;
    final double pageWidth = page.getClientSize().width;
    final double pageHeight = page.getClientSize().height;
    final double margin = 40;

    double y = 40;

    // 1. Header
    y = _drawHeader(
      g,
      shopSettings,
      titleFont,
      regularFont,
      mediumFont, // Use medium font for "INVOICE" label
      pageWidth,
      y,
      margin,
    );

    // 2. Invoice Info
    y = _drawInvoiceInfo(
      g,
      cashMemo,
      mediumFont,
      boldFont,
      regularFont,
      y,
      pageWidth,
      margin,
    );

    // 3. Items Table
    final PdfLayoutResult tableResult = _drawItemsTable(
      page,
      cashMemo,
      boldFont,
      regularFont,
      y + 20,
      pageWidth,
      margin,
    );
    y = tableResult.bounds.bottom + 30;

    // 4. Footer Section (Updated to fix overlapping)
    y = _drawFooterSection(
      page, // Pass 'page' instead of 'g' for better layout control
      cashMemo,
      shopSettings,
      mediumFont,
      boldFont,
      regularFont,
      y,
      pageWidth,
      margin,
    );

    // 5. Bottom Bar
    _drawBottomBar(g, shopSettings, pageWidth, pageHeight, margin, regularFont);

    // Save and Print
    final List<int> bytes = await document.save();
    document.dispose();

    await Printing.layoutPdf(
      onLayout: (_) => Future.value(Uint8List.fromList(bytes)),
    );
  }

  // FIXED: Adjusted bounds for Shop Name so it doesn't disappear
  static double _drawHeader(
    PdfGraphics g,
    ShopSettings s,
    PdfFont titleFont,
    PdfFont tagFont,
    PdfFont invoiceFont,
    double width,
    double y,
    double margin,
  ) {
    const double logoSize = 36;

    // Diamond Logo
    g.drawPolygon([
      Offset(margin + logoSize / 2, y),
      Offset(margin + logoSize, y + logoSize / 2),
      Offset(margin + logoSize / 2, y + logoSize),
      Offset(margin, y + logoSize / 2),
    ], pen: PdfPen(_darkColor, width: 2.5));

    // Shop Name
    // Fix: Increased height to 50 and added vertical alignment
    final double textX = margin + logoSize + 15;

    g.drawString(
      s.shopName.isNotEmpty ? s.shopName : "Shop Name", // Fallback
      titleFont,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(textX, y - 5, 350, 50),
      format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
    );

    // Tagline
    g.drawString(
      s.tagline ?? 'Your tagline here',
      tagFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(textX, y + 35, 300, 20),
    );

    // INVOICE text
    final Size invoiceSize = invoiceFont.measureString('INVOICE');
    g.drawString(
      'INVOICE',
      invoiceFont, // Used medium/bold font
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(
        width - margin - invoiceSize.width,
        y + 10,
        invoiceSize.width,
        invoiceSize.height,
      ),
    );

    // Yellow bars
    final double barY = y + 70;
    g.drawRectangle(
      bounds: Rect.fromLTWH(0, barY, width * 0.58, 28),
      brush: PdfSolidBrush(_yellowColor),
    );
    g.drawRectangle(
      bounds: Rect.fromLTWH(width * 0.82, barY, width * 0.18, 28),
      brush: PdfSolidBrush(_yellowColor),
    );

    return barY + 50;
  }

  static double _drawInvoiceInfo(
    PdfGraphics g,
    CashMemo cm,
    PdfFont title,
    PdfFont bold,
    PdfFont regular,
    double y,
    double width,
    double margin,
  ) {
    double maxY = y;

    // Left: Invoice to
    g.drawString(
      'Invoice to:',
      title,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(margin, y, 200, 25),
    );
    double leftY = y + 28;

    if (cm.customerName != null && cm.customerName!.isNotEmpty) {
      g.drawString(
        cm.customerName!,
        bold,
        brush: PdfSolidBrush(_textColor),
        bounds: Rect.fromLTWH(margin, leftY, 280, 20),
      );
      leftY += 22;
    }
    if (cm.customerAddress != null && cm.customerAddress!.isNotEmpty) {
      // Use PdfTextElement here too if address is very long,
      // but drawString with wrap format works for short multiline
      g.drawString(
        cm.customerAddress!,
        regular,
        brush: PdfSolidBrush(_textColor),
        bounds: Rect.fromLTWH(margin, leftY, 280, 60),
        format: PdfStringFormat(
          lineAlignment: PdfVerticalAlignment.top,
          wordWrap: PdfWordWrapType.word,
        ),
      );
      leftY += 50;
    }
    maxY = leftY > maxY ? leftY : maxY;

    // Right: Invoice# & Date
    double rightY = y + 5;
    final double rightX = width - margin - 250;

    g.drawString(
      'Invoice#',
      bold,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(rightX, rightY, 90, 20),
    );
    g.drawString(
      cm.memoNumber,
      bold,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(rightX + 100, rightY, 150, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
    rightY += 28;

    g.drawString(
      'Date',
      bold,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(rightX, rightY, 90, 20),
    );
    g.drawString(
      DateFormat('dd / MM / yyyy').format(cm.date),
      bold,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(rightX + 100, rightY, 150, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );

    return maxY > rightY + 30 ? maxY + 20 : rightY + 50;
  }

  static PdfLayoutResult _drawItemsTable(
    PdfPage page,
    CashMemo cm,
    PdfFont bold,
    PdfFont regular,
    double y,
    double width,
    double margin,
  ) {
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);
    final double tableWidth = width - margin * 2;

    grid.columns[0].width = tableWidth * 0.08;
    grid.columns[1].width = tableWidth * 0.42;
    grid.columns[2].width = tableWidth * 0.15;
    grid.columns[3].width = tableWidth * 0.15;
    grid.columns[4].width = tableWidth * 0.20;

    final PdfGridRow header = grid.headers.add(1)[0];
    header.cells[0].value = 'SL.';
    header.cells[1].value = 'Item Description';
    header.cells[2].value = 'Price';
    header.cells[3].value = 'Qty.';
    header.cells[4].value = 'Total';

    for (int i = 0; i < 5; i++) {
      header.cells[i].style = PdfGridCellStyle(
        backgroundBrush: PdfSolidBrush(_darkColor),
        textBrush: PdfSolidBrush(_whiteColor),
        font: bold,
        cellPadding: PdfPaddings(left: 6, top: 8, right: 6, bottom: 8),
      );
      header.cells[i].stringFormat = PdfStringFormat(
        alignment: i < 2 ? PdfTextAlignment.left : PdfTextAlignment.right,
        lineAlignment: PdfVerticalAlignment.middle,
      );
    }

    for (int i = 0; i < cm.items.length; i++) {
      final item = cm.items[i];
      final row = grid.rows.add();
      row.cells[0].value = '${i + 1}';
      row.cells[1].value = item.productName;
      row.cells[2].value = item.price.toStringAsFixed(2);
      row.cells[3].value = item.quantity.toString();
      row.cells[4].value = item.total.toStringAsFixed(2);

      final color = i.isEven ? _whiteColor : _lightGrayColor;
      for (int j = 0; j < 5; j++) {
        row.cells[j].style = PdfGridCellStyle(
          backgroundBrush: PdfSolidBrush(color),
          textBrush: PdfSolidBrush(_textColor),
          font: regular,
          cellPadding: PdfPaddings(left: 6, top: 8, right: 6, bottom: 8),
        );
        row.cells[j].stringFormat = PdfStringFormat(
          alignment: j < 2 ? PdfTextAlignment.left : PdfTextAlignment.right,
          lineAlignment: PdfVerticalAlignment.middle,
        );
      }
    }

    return grid.draw(
      page: page,
      bounds: Rect.fromLTWH(margin, y, tableWidth, 0),
    )!;
  }

  // FIXED: Using PdfTextElement for dynamic layout to prevent overlapping
  static double _drawFooterSection(
    PdfPage page, // Changed from PdfGraphics to PdfPage
    CashMemo cm,
    ShopSettings? settings,
    PdfFont medium,
    PdfFont bold,
    PdfFont regular,
    double y,
    double width,
    double margin,
  ) {
    final PdfGraphics g = page.graphics;
    double currentY = y;
    double maxY = y;

    // Thank you message
    g.drawString(
      'Thank you for your business',
      bold,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(margin, currentY, 350, 25),
    );
    currentY += 35;

    // --- LEFT SIDE: Terms & Payment ---

    // Terms Header
    g.drawString(
      'Terms & Conditions',
      bold,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(margin, currentY, 300, 20),
    );
    currentY += 22;

    // Terms Body (Dynamic Height)
    // Fix: Using PdfTextElement ensures text wraps and we get the exact bottom Y
    String termsText =
        settings?.terms ??
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce dignissim pretium consectetur.';

    PdfTextElement termsElement = PdfTextElement(
      text: termsText,
      font: regular,
      brush: PdfSolidBrush(_textColor),
      format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.top),
    );

    PdfLayoutResult? termsResult = termsElement.draw(
      page: page,
      bounds: Rect.fromLTWH(margin, currentY, 300, 0),
    );

    // Update Y based on where the text actually ended
    if (termsResult != null) {
      currentY = termsResult.bounds.bottom + 25;
    } else {
      currentY += 40; // Fallback
    }

    // Payment Info
    final paymentLines = [
      ['Account #:', '1234 5678 9012'],
      ['A/C Name:', settings?.shopName ?? 'My Grocery Shop'],
      ['Bank Details:', 'Your bank name and branch'],
    ];

    for (var line in paymentLines) {
      g.drawString(
        line[0],
        bold,
        brush: PdfSolidBrush(_darkColor),
        bounds: Rect.fromLTWH(margin, currentY, 90, 18),
      );
      g.drawString(
        line[1],
        regular,
        brush: PdfSolidBrush(_textColor),
        bounds: Rect.fromLTWH(margin + 100, currentY, 210, 18),
      );
      currentY += 20;
    }

    maxY = currentY + 20; // This is the bottom of the left side

    // --- RIGHT SIDE: Totals ---
    // We reset Y for the right side calculation, but keep X aligned to right
    double rightY = y + 35;
    final double rightX = width - margin - 260;
    final double boxWidth = 260;

    // Sub Total
    _drawTotalLine(
      g,
      'Sub Total:',
      cm.subtotal,
      bold,
      rightX,
      rightY,
      boxWidth,
    );
    rightY += 28;

    // Tax
    _drawTotalLine(g, 'Tax:', cm.tax, bold, rightX, rightY, boxWidth);
    rightY += 35;

    // Total Box
    g.drawRectangle(
      brush: PdfSolidBrush(_yellowColor),
      bounds: Rect.fromLTWH(rightX, rightY, boxWidth, 40),
    );
    g.drawString(
      'Total:',
      medium,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(rightX + 15, rightY + 10, 100, 25),
    );
    g.drawString(
      '${AppConstants.currencySymbol}${cm.total.toStringAsFixed(2)}',
      medium,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(rightX + 110, rightY + 10, boxWidth - 125, 25),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
    rightY += 50;

    // Return the larger Y value so subsequent elements don't overlap
    return maxY > rightY ? maxY : rightY;
  }

  static void _drawTotalLine(
    PdfGraphics g,
    String label,
    double value,
    PdfFont font,
    double x,
    double y,
    double width,
  ) {
    g.drawString(
      label,
      font,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(x, y, width / 2, 20),
    );
    g.drawString(
      '${AppConstants.currencySymbol}${value.toStringAsFixed(2)}',
      font,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(x + width / 2, y, width / 2 - 10, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
  }

  static void _drawBottomBar(
    PdfGraphics g,
    ShopSettings? settings,
    double width,
    double height,
    double margin,
    PdfFont font,
  ) {
    final double barY = height - 45;

    // Yellow bars
    g.drawRectangle(
      bounds: Rect.fromLTWH(0, barY, width * 0.65, 6),
      brush: PdfSolidBrush(_yellowColor),
    );
    g.drawRectangle(
      bounds: Rect.fromLTWH(width * 0.88, barY, width * 0.12, 6),
      brush: PdfSolidBrush(_yellowColor),
    );

    // Contact text
    g.drawString(
      'Phone # ${settings?.phone ?? ''}   |   Address ${settings?.address ?? ''}',
      font,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(margin + 10, height - 30, 400, 20),
    );

    // Signature
    final double signX = width - margin - 180;
    g.drawLine(
      PdfPen(_darkColor),
      Offset(signX, height - 70),
      Offset(signX + 180, height - 70),
    );
    g.drawString(
      'Authorised Sign',
      font,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(signX, height - 55, 180, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
  }
}
