import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:bangla_pdf/bangla_pdf.dart';

// Update imports based on your actual folder structure
import '../../domain/entities/cash_memo.dart';
import '../../domain/entities/shop_settings.dart';
import '../constants/app_constants.dart';

class PdfService {
  // Colors
  static const PdfColor _yellowColor = PdfColor.fromInt(0xFFFFC107); // Amber
  static const PdfColor _darkColor = PdfColor.fromInt(0xFF333333);

  static Future<void> generateAndPrintCashMemo(
    CashMemo cashMemo,
    ShopSettings shopSettings,
  ) async {
    try {
      // 1. Initialize Bangla Fonts (REQUIRED by the package)
      await BanglaFontManager().initialize();
    } catch (e) {
      print('Warning: Failed to initialize Bangla fonts: $e');
    }

    // Load logo asset (if available)
    Uint8List? logoBytes;
    try {
      final data = await rootBundle.load('assets/logo/logo .png');
      logoBytes = data.buffer.asUint8List();
    } catch (e) {
      // If the asset isn't found or failed to load, just leave it null.
      print('Warning: Could not load logo asset: $e');
      logoBytes = null;
    }

    final pdf = pw.Document();

    // We don't need to manually load fonts anymore!
    // The package handles it via BanglaFontType.

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return [
            _buildHeader(shopSettings, logoBytes),

            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40),
              child: pw.Column(
                children: [
                  _buildInvoiceInfo(cashMemo),
                  pw.SizedBox(height: 20),
                  _buildItemsTable(cashMemo),
                  pw.SizedBox(height: 20),
                  _buildFooterSection(cashMemo, shopSettings),
                ],
              ),
            ),
          ];
        },
        footer: (context) => _buildBottomBar(shopSettings),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // --- 1. HEADER ---
  static pw.Widget _buildHeader(ShopSettings settings, Uint8List? logoBytes) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 40),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 40),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(width: 10),
              // Logo (use asset if available; otherwise show placeholder)
              logoBytes != null
                  ? pw.Container(
                      width: 36,
                      height: 36,
                      child: pw.Center(
                        child: pw.Image(
                          pw.MemoryImage(logoBytes),
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                    )
                  : pw.Container(
                      width: 36,
                      height: 36,
                      transform: Matrix4.rotationZ(0.785398),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: _darkColor, width: 2.5),
                      ),
                    ),
              pw.SizedBox(width: 30),

              // Shop Name
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Using BanglaAutoText for potential Bengali shop names
                  BanglaAutoText(
                    settings.shopName.isNotEmpty
                        ? settings.shopName
                        : "Brand Name",
                    // fontType: BanglaFontType.kalpurush,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: _darkColor,
                  ),
                  BanglaAutoText(
                    settings.tagline ?? 'Your tagline here',
                    // fontType: BanglaFontType.kalpurush,
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),

        // Yellow Bar & INVOICE
        pw.Row(
          children: [
            pw.Container(
              width: PdfPageFormat.a4.width * 0.55,
              height: 35,
              color: _yellowColor,
            ),
            pw.SizedBox(width: 15),
            pw.Text(
              'INVOICE', // English text can use standard Text widget
              style: pw.TextStyle(
                fontSize: 35,
                fontWeight: pw.FontWeight.bold,
                color: _darkColor,
              ),
            ),
            pw.SizedBox(width: 15),
            pw.Expanded(child: pw.Container(height: 35, color: _yellowColor)),
          ],
        ),
        pw.SizedBox(height: 30),
      ],
    );
  }

  // --- 2. INVOICE INFO ---
  static pw.Widget _buildInvoiceInfo(CashMemo memo) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        // Left: To
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Invoice to:',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: _darkColor,
              ),
            ),
            pw.SizedBox(height: 8),
            if (memo.customerName != null && memo.customerName!.isNotEmpty)
              BanglaAutoText(
                memo.customerName!,
                // fontType: BanglaFontType.kalpurush,
                fontWeight: pw.FontWeight.bold,
              ),
            if (memo.customerAddress != null &&
                memo.customerAddress!.isNotEmpty)
              pw.SizedBox(
                width: 250,
                child: BanglaAutoText(
                  memo.customerAddress!,
                  // fontType: BanglaFontType.kalpurush,
                ),
              ),
          ],
        ),
        // Right: Info
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildLabelValueRow('Invoice#', memo.memoNumber),
            pw.SizedBox(height: 5),
            _buildLabelValueRow(
              'Date',
              DateFormat('dd / MM / yyyy').format(memo.date),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildLabelValueRow(String label, String value) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.SizedBox(
          width: 80,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: _darkColor,
            ),
          ),
        ),
        // Value might contain Bangla (if you use Bangla numerals later), so safe to use BanglaAutoText
        BanglaAutoText(
          value,
          // fontType: BanglaFontType.kalpurush,
          fontWeight: pw.FontWeight.bold,
        ),
      ],
    );
  }

  // --- 3. ITEMS TABLE ---
  static pw.Widget _buildItemsTable(CashMemo memo) {
    // Convert data for table
    final List<List<String>> tableData = [
      ['SL.', 'Item Description', 'Price', 'Qty.', 'Total'], // Header
      ...memo.items.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final item = entry.value;
        return [
          '$index',
          item.productName, // This is likely Bangla
          item.price.toStringAsFixed(2),
          item.quantity.toString(),
          item.total.toStringAsFixed(2),
        ];
      }),
    ];

    // Use BanglaTable from the package!
    // It handles the styling and font fixing automatically.
    return BanglaTable(
      data: tableData,
      fontType: BanglaFontType.kalpurush,
      fontSize: 10,
      // headerTextStyle: BanglaFontType.kalpurush.ts(
      //   color: _whiteColor,
      //   fontWeight: pw.FontWeight.bold,
      //   fontSize: 10,
      // ),
      // cellTextStyle: BanglaFontType.kalpurush.ts(
      //   color: _darkColor,
      //   fontSize: 10,
      // ),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: const pw.FixedColumnWidth(30), // SL
        1: const pw.FlexColumnWidth(4), // Desc
        2: const pw.FlexColumnWidth(1.5), // Price
        3: const pw.FlexColumnWidth(1), // Qty
        4: const pw.FlexColumnWidth(2), // Total
      },
      // Custom decoration to match your design
      // headerDecoration: const pw.BoxDecoration(color: _darkColor),
      // rowDecoration: const pw.BoxDecoration(color: _whiteColor),
      // oddRowDecoration: const pw.BoxDecoration(color: _lightGrayColor),
    );
  }

  // --- 4. FOOTER SECTION ---
  static pw.Widget _buildFooterSection(CashMemo memo, ShopSettings settings) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // --- LEFT SIDE ---
        pw.Expanded(
          flex: 6,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Thank you for your business',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: _darkColor,
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Text(
                'Terms & Conditions',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: _darkColor,
                ),
              ),
              pw.SizedBox(height: 5),

              // *** THIS FIXES THE BENGALI TEXT ISSUES AUTOMATICALLY ***
              BanglaAutoText(
                settings.terms != null && settings.terms!.isNotEmpty
                    ? settings.terms!
                    : 'No terms and conditions provided.',
                // fontType: BanglaFontType.kalpurush,
                fontSize: 10,
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                'Invoice By:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: _darkColor,
                ),
              ),
              pw.SizedBox(height: 5),
              _buildSimpleRow('Name:', settings.invoiceByName ?? 'Zaman'),
              _buildSimpleRow('Role:', settings.invoiceByRole ?? 'Dev'),
              _buildSimpleRow(
                'Contact:',
                settings.invoiceByContact ?? '01735069723',
              ),
            ],
          ),
        ),

        pw.SizedBox(width: 20),

        // --- RIGHT SIDE ---
        pw.Expanded(
          flex: 4,
          child: pw.Column(
            children: [
              _buildTotalRow('Sub Total:', memo.subtotal),
              pw.SizedBox(height: 10),
              _buildTotalRow('Tax:', memo.tax),
              pw.SizedBox(height: 20),

              pw.Container(
                color: _yellowColor,
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total:',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: _darkColor,
                      ),
                    ),
                    // Use BanglaAutoText here just in case currency symbol or numbers need shaping
                    BanglaAutoText(
                      '${AppConstants.currencySymbol}${memo.total.toStringAsFixed(2)}',
                      // fontType: BanglaFontType.kalpurush,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                      color: _darkColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSimpleRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 60,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
          ),
          // Use BanglaAutoText for dynamic values that might be in Bengali
          BanglaAutoText(
            value,
            // fontType: BanglaFontType.kalpurush,
            fontSize: 10,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, double value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: _darkColor,
          ),
        ),
        BanglaAutoText(
          '${AppConstants.currencySymbol}${value.toStringAsFixed(2)}',
          // fontType: BanglaFontType.kalpurush,
          fontWeight: pw.FontWeight.bold,
          color: _darkColor,
        ),
      ],
    );
  }

  // --- 5. BOTTOM BAR ---
  static pw.Widget _buildBottomBar(ShopSettings settings) {
    final pageWidth = PdfPageFormat.a4.width;

    return pw.Column(
      children: [
        pw.SizedBox(height: 10),

        // Yellow bars at top
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Container(
              width: pageWidth * 0.58,
              height: 5,
              color: _yellowColor,
            ),
            // Right: Signature with line
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(width: 150, height: 2, color: _darkColor),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Authorised Sign',
                    style: const pw.TextStyle(
                      fontSize: 14,
                      color: PdfColor(0, 0, 0),
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: pageWidth * 0.15,
              height: 5,
              color: _yellowColor,
            ),
          ],
        ),

        pw.SizedBox(height: 15),

        // Contact and Signature on same line
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 40),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // Left: Contact Info
              pw.Text(
                'Phone # ${settings.phone}   |   Address: ${settings.address}  ',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor(0, 0, 0),
                ),
              ),
              // Right: Spacer
              pw.Spacer(),
            ],
          ),
        ),

        pw.SizedBox(height: 15),
      ],
    );
  }
}
