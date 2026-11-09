const PDFDocument = require('pdfkit');
const path = require('path');

/**
 * Initialise a PDFDocument, set response headers and pipe to the client.
 * @param {object} res Express response object
 * @param {object} options { filename: string, inline?: boolean }
 * @returns {PDFDocument}
 */
function initPDFResponse(res, { filename, inline = false }) {
  const doc = new PDFDocument({ margin: 40, size: 'A4' });
  res.setHeader('Content-Type', 'application/pdf');
  const disposition = inline ? 'inline' : `attachment; filename=${filename}`;
  res.setHeader('Content-Disposition', disposition);
  // Pipe the PDF stream to the response
  doc.pipe(res);
  return doc;
}

/** Draws the outer border used in many reports */
function drawBorder(doc) {
  doc.rect(15, 15, 565, 810).stroke();
}

/** Insert the college logo if it exists */
function drawLogo(doc) {
  const logoPath = path.join(__dirname, '../assets/college-logo.png');
  try {
    doc.image(logoPath, 40, 30, { width: 55 });
  } catch (_) {
    // Silently ignore missing logo – layout continues
  }
}

/** Common header used across PDFs */
function drawHeader(doc) {
  doc.fontSize(18).text('MES M.K. MACKAR PILLAY COLLEGE', 110, 35);
  doc.fontSize(11).text('FOR ADVANCED STUDIES, EDATHALA', 110, 60);
  doc.fontSize(8).text('Affiliated to Mahatma Gandhi University', 110, 80);
}

/** Title centered below the header */
function drawTitle(doc, title) {
  doc.moveDown(4);
  doc.fontSize(16).text(title, { align: 'center' });
  doc.moveDown();
}

/** Footer with generated timestamp */
function drawFooter(doc) {
  doc.fontSize(8);
  doc.text(`Generated On : ${new Date().toLocaleString()}`, 40, 780);
  doc.text('Generated from College ERP System', 40, 795);
}

/** Signatures section */
function drawSignatures(doc, y = 700) {
  doc.moveTo(60, y).lineTo(180, y).stroke();
  doc.moveTo(380, y).lineTo(500, y).stroke();
  doc.fontSize(10);
  doc.text('Class In-Charge', 60, y + 5);
  doc.text('Head of Department', 380, y + 5);
}

module.exports = {
  initPDFResponse,
  drawBorder,
  drawLogo,
  drawHeader,
  drawTitle,
  drawFooter,
  drawSignatures,
};
