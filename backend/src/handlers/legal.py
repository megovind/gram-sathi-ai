"""
Legal handler

GET /legal/privacy-policy  – HTML privacy policy (public, no auth)
"""

from src.utils.response import error, html

_LAST_UPDATED = "1 March 2026"
_CONTACT_EMAIL = "privacy@gramsathi.in"
_APP_NAME = "GramSathi"
_COMPANY = "GramSathi AI"


def handler(event: dict, context) -> dict:
    method = event.get("httpMethod", "GET")
    path = event.get("path", "")

    if method == "GET" and path.endswith("/privacy-policy"):
        return html(_privacy_policy_html())

    return error("Not found", 404)


# ---------------------------------------------------------------------------
# HTML content
# ---------------------------------------------------------------------------

def _privacy_policy_html() -> str:
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{_APP_NAME} – Privacy Policy</title>
  <style>
    *, *::before, *::after {{ box-sizing: border-box; margin: 0; padding: 0; }}
    :root {{
      --brand: #2563EB;
      --brand-light: #EFF6FF;
      --text: #1E293B;
      --muted: #64748B;
      --border: #E2E8F0;
      --bg: #F8FAFC;
      --card: #FFFFFF;
      --radius: 12px;
      --max-w: 860px;
    }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
      background: var(--bg);
      color: var(--text);
      line-height: 1.7;
      padding: 0 16px 64px;
    }}
    header {{
      background: var(--brand);
      color: #fff;
      padding: 32px 24px;
      text-align: center;
      margin: 0 -16px 48px;
    }}
    header h1 {{ font-size: 1.9rem; font-weight: 700; letter-spacing: -0.5px; }}
    header p  {{ margin-top: 6px; opacity: 0.85; font-size: 0.95rem; }}
    .container {{ max-width: var(--max-w); margin: 0 auto; }}
    .meta {{
      background: var(--brand-light);
      border-left: 4px solid var(--brand);
      border-radius: var(--radius);
      padding: 16px 20px;
      margin-bottom: 40px;
      font-size: 0.9rem;
      color: var(--brand);
    }}
    .meta strong {{ font-weight: 600; }}
    section {{
      background: var(--card);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      padding: 28px 32px;
      margin-bottom: 24px;
      box-shadow: 0 1px 3px rgba(0,0,0,.04);
    }}
    h2 {{
      font-size: 1.15rem;
      font-weight: 700;
      color: var(--brand);
      margin-bottom: 14px;
      display: flex;
      align-items: center;
      gap: 8px;
    }}
    h2 .num {{
      background: var(--brand);
      color: #fff;
      border-radius: 50%;
      width: 28px;
      height: 28px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      font-size: 0.8rem;
      flex-shrink: 0;
    }}
    p {{ margin-bottom: 12px; }}
    p:last-child {{ margin-bottom: 0; }}
    ul, ol {{ margin: 10px 0 12px 22px; }}
    li {{ margin-bottom: 6px; }}
    table {{
      width: 100%;
      border-collapse: collapse;
      margin: 14px 0;
      font-size: 0.9rem;
    }}
    th {{
      background: var(--brand-light);
      color: var(--brand);
      font-weight: 600;
      text-align: left;
      padding: 10px 14px;
      border: 1px solid var(--border);
    }}
    td {{
      padding: 9px 14px;
      border: 1px solid var(--border);
      vertical-align: top;
    }}
    tr:nth-child(even) td {{ background: var(--bg); }}
    .badge {{
      display: inline-block;
      background: var(--brand-light);
      color: var(--brand);
      font-size: 0.78rem;
      font-weight: 600;
      padding: 2px 8px;
      border-radius: 99px;
      border: 1px solid #BFDBFE;
    }}
    .highlight {{
      background: #FEF9C3;
      border: 1px solid #FDE047;
      border-radius: 8px;
      padding: 12px 16px;
      margin: 14px 0;
      font-size: 0.9rem;
    }}
    a {{ color: var(--brand); text-decoration: none; }}
    a:hover {{ text-decoration: underline; }}
    footer {{
      text-align: center;
      margin-top: 48px;
      font-size: 0.85rem;
      color: var(--muted);
    }}
    @media (max-width: 600px) {{
      section {{ padding: 20px 18px; }}
      header h1 {{ font-size: 1.4rem; }}
    }}
  </style>
</head>
<body>

<header>
  <h1>🌾 {_APP_NAME} – Privacy Policy</h1>
  <p>Your privacy matters to us. This policy explains what we collect, why, and how you can control it.</p>
</header>

<div class="container">

  <div class="meta">
    <strong>Last updated:</strong> {_LAST_UPDATED} &nbsp;·&nbsp;
    <strong>Applies to:</strong> {_APP_NAME} Android &amp; iOS app, WhatsApp service, and backend API &nbsp;·&nbsp;
    <strong>Contact:</strong> <a href="mailto:{_CONTACT_EMAIL}">{_CONTACT_EMAIL}</a>
  </div>

  <!-- 1. Who We Are -->
  <section>
    <h2><span class="num">1</span> Who We Are</h2>
    <p>
      <strong>{_COMPANY}</strong> operates the <strong>{_APP_NAME}</strong> mobile application and related services.
      {_APP_NAME} is a voice-first AI assistant designed to help rural communities in India access
      health guidance and connect with local shops. Our registered address and data controller contact
      is reachable at <a href="mailto:{_CONTACT_EMAIL}">{_CONTACT_EMAIL}</a>.
    </p>
    <p>
      This Privacy Policy applies to all users of the {_APP_NAME} mobile app (Android and iOS),
      the {_APP_NAME} WhatsApp service, and any API interactions with our backend.
    </p>
  </section>

  <!-- 2. What Data We Collect -->
  <section>
    <h2><span class="num">2</span> What Data We Collect</h2>
    <table>
      <thead>
        <tr>
          <th>Data Type</th>
          <th>What exactly</th>
          <th>Why we need it</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><span class="badge">Identity</span></td>
          <td>Mobile phone number, optional name</td>
          <td>Create and identify your account; deliver SMS order notifications</td>
        </tr>
        <tr>
          <td><span class="badge">Location</span></td>
          <td>Device GPS coordinates (latitude &amp; longitude) or pincode you enter</td>
          <td>Find nearby clinics, hospitals, pharmacies, and local shops within 5 km</td>
        </tr>
        <tr>
          <td><span class="badge">Audio</span></td>
          <td>Short voice recordings you make inside the app</td>
          <td>Convert speech to text so you can talk to the AI assistant hands-free</td>
        </tr>
        <tr>
          <td><span class="badge">Conversations</span></td>
          <td>Text messages and AI replies in your chat sessions</td>
          <td>Provide contextual AI responses; let you review past advice; generate doctor summaries</td>
        </tr>
        <tr>
          <td><span class="badge">App Preferences</span></td>
          <td>Your chosen language (one of 8 Indian languages)</td>
          <td>Show the app in your preferred language</td>
        </tr>
        <tr>
          <td><span class="badge">Commerce</span> (shop owners)</td>
          <td>Shop name, address, pincode, phone, inventory items, order history</td>
          <td>Display your shop to customers; process orders; send order notifications</td>
        </tr>
        <tr>
          <td><span class="badge">WhatsApp</span></td>
          <td>WhatsApp phone number and message text (if you use our WhatsApp service)</td>
          <td>Process and respond to your messages through our AI assistant</td>
        </tr>
      </tbody>
    </table>
    <div class="highlight">
      ⚠️ <strong>We do not collect:</strong> camera photos, payment card details, Aadhaar number,
      financial account information, or any biometric data.
    </div>
  </section>

  <!-- 3. How We Use Your Data -->
  <section>
    <h2><span class="num">3</span> How We Use Your Data</h2>
    <ul>
      <li><strong>Provide the service</strong> – process your voice or text queries and return AI-generated responses.</li>
      <li><strong>Health guidance</strong> – analyse symptoms you describe and suggest when to seek care. <em>This is not a medical diagnosis.</em> A disclaimer is always included with health responses.</li>
      <li><strong>Nearby facility search</strong> – use your GPS or pincode to query OpenStreetMap for clinics and pharmacies near you.</li>
      <li><strong>Commerce</strong> – match your pincode to local shops, process orders, and notify shop owners by SMS.</li>
      <li><strong>Improve response quality</strong> – cache frequent queries (anonymised SHA-256 hash of language + query text) to reduce AI processing time and cost.</li>
      <li><strong>Security</strong> – sign and verify JSON Web Tokens to authenticate your session.</li>
      <li><strong>Service reliability</strong> – log errors and performance metrics in AWS CloudWatch (no PII in logs).</li>
    </ul>
    <p>We do <strong>not</strong> use your data for advertising, profiling, or sale to third parties.</p>
  </section>

  <!-- 4. AI-Generated Responses -->
  <section>
    <h2><span class="num">4</span> AI-Generated Responses</h2>
    <p>
      Responses in {_APP_NAME} are generated by an AI system (Amazon Bedrock – Claude 3 Haiku by Anthropic).
      AI responses are provided for <strong>informational purposes only</strong> and do not constitute
      professional medical, legal, or financial advice.
    </p>
    <p>
      Every health-related response includes a mandatory disclaimer in your chosen language reminding
      you to consult a qualified doctor for medical decisions.
    </p>
    <p>
      For critical symptoms (e.g., chest pain, difficulty breathing, seizures), the app immediately
      advises you to call emergency services — no AI processing delay.
    </p>
  </section>

  <!-- 5. Data Sharing -->
  <section>
    <h2><span class="num">5</span> Third-Party Services We Use</h2>
    <p>We share the minimum necessary data with trusted sub-processors to operate {_APP_NAME}:</p>
    <table>
      <thead>
        <tr>
          <th>Service</th>
          <th>Provider</th>
          <th>Data shared</th>
          <th>Purpose</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Cloud infrastructure (Lambda, DynamoDB, S3)</td>
          <td>Amazon Web Services (AWS) – <em>ap-south-1</em> region (Mumbai, India)</td>
          <td>All app data</td>
          <td>Hosting and data storage</td>
        </tr>
        <tr>
          <td>Speech-to-text</td>
          <td>Amazon Transcribe (AWS)</td>
          <td>Audio recordings</td>
          <td>Convert your voice to text</td>
        </tr>
        <tr>
          <td>Text-to-speech</td>
          <td>Amazon Polly (AWS)</td>
          <td>AI response text</td>
          <td>Convert AI replies to audio</td>
        </tr>
        <tr>
          <td>AI language model</td>
          <td>Amazon Bedrock – Claude 3 Haiku (Anthropic)</td>
          <td>Your query text + last 4 conversation turns</td>
          <td>Generate intelligent responses</td>
        </tr>
        <tr>
          <td>Map / location search</td>
          <td>OpenStreetMap Overpass API &amp; Nominatim</td>
          <td>Your GPS coordinates or pincode</td>
          <td>Find nearby health facilities and shops</td>
        </tr>
        <tr>
          <td>SMS notifications</td>
          <td>Amazon SNS (AWS)</td>
          <td>Shop owner's phone number + order details</td>
          <td>Notify shop owners of new orders</td>
        </tr>
        <tr>
          <td>WhatsApp messaging</td>
          <td>Meta (WhatsApp Business API)</td>
          <td>WhatsApp phone number + message text</td>
          <td>Send and receive messages via WhatsApp</td>
        </tr>
      </tbody>
    </table>
    <p>
      All AWS services operate out of the <strong>ap-south-1 (Mumbai)</strong> region, meaning your data
      is stored and processed in India. AWS is certified under ISO 27001 and complies with applicable
      Indian data localisation practices.
    </p>
    <p>We do not sell, rent, or trade your personal data to any third party.</p>
  </section>

  <!-- 6. Data Retention -->
  <section>
    <h2><span class="num">6</span> Data Retention</h2>
    <table>
      <thead>
        <tr><th>Data</th><th>Retention period</th></tr>
      </thead>
      <tbody>
        <tr><td>Audio recordings (S3)</td><td>Automatically deleted after <strong>7 days</strong></td></tr>
        <tr><td>Conversation history</td><td>Retained for <strong>90 days</strong> from last activity, then permanently deleted</td></tr>
        <tr><td>User profile (phone, name, language)</td><td>Retained until you delete your account</td></tr>
        <tr><td>Order records</td><td>Retained for <strong>1 year</strong> for dispute resolution, then deleted</td></tr>
        <tr><td>Response cache</td><td>Expires after <strong>24 hours</strong> (TTL-based, no PII)</td></tr>
        <tr><td>Geocoding cache</td><td>Retained permanently (contains only place names and coordinates, no PII)</td></tr>
      </tbody>
    </table>
  </section>

  <!-- 7. Your Rights -->
  <section>
    <h2><span class="num">7</span> Your Rights</h2>
    <p>
      Under the <strong>Digital Personal Data Protection Act, 2023 (DPDPA)</strong> of India, and where
      applicable under the <strong>GDPR</strong>, you have the following rights:
    </p>
    <ul>
      <li><strong>Access</strong> – request a copy of the personal data we hold about you.</li>
      <li><strong>Correction</strong> – ask us to correct inaccurate data (e.g., update your name or language).</li>
      <li><strong>Deletion ("Right to be Forgotten")</strong> – request deletion of your account and all associated personal data. We will complete this within <strong>30 days</strong>.</li>
      <li><strong>Withdrawal of Consent</strong> – you may stop using the app at any time. Uninstalling the app stops all future data collection.</li>
      <li><strong>Grievance Redressal</strong> – if you believe your data rights have been violated, you can contact our Grievance Officer (see Section 10).</li>
    </ul>
    <div class="highlight">
      🗑️ <strong>To delete your account and all data</strong>, go to <em>Settings → Delete Account</em>
      in the app, or email <a href="mailto:{_CONTACT_EMAIL}">{_CONTACT_EMAIL}</a> with subject
      <em>"Data Deletion Request"</em> and your registered phone number. We will confirm deletion within 30 days.
    </div>
  </section>

  <!-- 8. Security -->
  <section>
    <h2><span class="num">8</span> Security</h2>
    <ul>
      <li>All data in transit is encrypted using <strong>TLS 1.2+</strong> (HTTPS).</li>
      <li>Your session token (JWT) is stored in your device's secure hardware-backed keystore
          (Android Keystore / iOS Keychain) via encrypted storage.</li>
      <li>Audio files in S3 are private (no public access) and accessible only via time-limited presigned URLs.</li>
      <li>AWS IAM policies follow the principle of least privilege — each service only has the permissions it needs.</li>
      <li>Your phone number is never included in AI requests sent to Amazon Bedrock.</li>
      <li>We use HMAC-SHA256 signature verification for all WhatsApp webhook messages.</li>
    </ul>
  </section>

  <!-- 9. Children -->
  <section>
    <h2><span class="num">9</span> Children's Privacy</h2>
    <p>
      {_APP_NAME} is not directed at children under the age of <strong>13</strong>. We do not knowingly
      collect personal information from children under 13. If you believe a child has provided us with
      personal information, please contact us at <a href="mailto:{_CONTACT_EMAIL}">{_CONTACT_EMAIL}</a>
      and we will delete it promptly.
    </p>
  </section>

  <!-- 10. Contact -->
  <section>
    <h2><span class="num">10</span> Contact &amp; Grievance Officer</h2>
    <p>
      For any privacy questions, data requests, or grievances under the DPDPA 2023:
    </p>
    <table>
      <tbody>
        <tr><td><strong>Email</strong></td><td><a href="mailto:{_CONTACT_EMAIL}">{_CONTACT_EMAIL}</a></td></tr>
        <tr><td><strong>Subject line</strong></td><td>Use "Privacy" or "Data Request" so we can prioritise</td></tr>
        <tr><td><strong>Response time</strong></td><td>Within 7 business days for enquiries; 30 days for deletion requests</td></tr>
      </tbody>
    </table>
  </section>

  <!-- 11. Changes -->
  <section>
    <h2><span class="num">11</span> Changes to This Policy</h2>
    <p>
      We may update this policy as the app evolves. When we make material changes, we will update the
      <strong>Last updated</strong> date at the top of this page and, where required by law, notify you
      through the app or by SMS. Continued use of {_APP_NAME} after the effective date of changes
      constitutes acceptance of the revised policy.
    </p>
  </section>

</div>

<footer>
  &copy; 2026 {_COMPANY} · <a href="mailto:{_CONTACT_EMAIL}">{_CONTACT_EMAIL}</a>
</footer>

</body>
</html>"""
