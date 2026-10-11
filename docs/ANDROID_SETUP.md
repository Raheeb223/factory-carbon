# Run the app on your Android phone / ফোনে অ্যাপ চালানো

Everything below is already prepared in this repository:
- Flutter SDK at `C:\src\flutter`.
- Backend settings in `backend\.env`, with an app token already generated.
- The matching app settings in `app\env\dev.json`.
- An Android Studio run configuration called **Factory Carbon (dev)**.

---

## English

### 1. One-time Android Studio setup (about 10 minutes)

1. Open **Android Studio** → **More Actions / Settings** → **Plugins**. Install **Flutter** (Dart comes with it) and restart.
2. **Settings → Languages & Frameworks → Flutter** → Flutter SDK path: `C:\src\flutter`.
3. **Tools → SDK Manager → SDK Tools** tab:
   - Tick **Show Package Details**.
   - Under **NDK (Side by side)**, tick version **28.2.13676358**.
   - Tick **Android SDK Command-line Tools (latest)**.
   - Click **Apply**. The build needs the NDK; my test build stopped at exactly this point.
4. Open a terminal (PowerShell) and accept the Android licenses (read them, then type `y`):
   ```
   C:\src\flutter\bin\flutter doctor --android-licenses
   ```
5. Check: `C:\src\flutter\bin\flutter doctor`. **Android toolchain** should show ✓.

> If downloads fail with a "certificate" or "PKIX" error, an antivirus or proxy is inspecting HTTPS. Turn off "HTTPS scanning" (or add Android Studio / Java as an exception) while installing, or use another network.

### 2. Connect your phone

1. On the phone: **Settings → About phone** → tap **Build number** 7 times. Developer options are now on.
2. **Settings → System → Developer options** → turn on **USB debugging**.
3. Connect the phone by USB and tap **Allow** on the "Allow USB debugging?" prompt.
4. In Android Studio the phone appears in the device list at the top.

### 3. Start the backend on your computer

In the `factory-carbon` folder, run in PowerShell:

```
powershell -ExecutionPolicy Bypass -File .\start_backend.ps1
```

It prints the **server address** (for example `192.168.1.20:8000`) and the **app token**. Keep this window open.

- The phone and the computer must be on the **same Wi-Fi**.
- If Windows asks about the firewall for Python, allow **Private networks**.

### 4. Run the app

1. Android Studio → **File → Open** → choose the `factory-carbon\app` folder.
2. Pick the run configuration **Factory Carbon (dev)**, select your phone, press ▶ **Run**. The first build takes several minutes.
3. In the app: **Settings → Server connection**.
   - Enter the server address and the app token printed by the script.
   - Tap **Test connection**, then **Save**.
4. Try it: **Settings → Load demo data**, then open **Reports**.

### 5. Turn on bill reading (when you have the Gemini key)

Open `backend\.env`, paste the key after `GEMINI_API_KEY=`, save, and restart `start_backend.ps1`. Until then, "Enter manually" works for every bill.

For real bills, use a Gemini project with billing enabled. On the free tier Google may use uploads to improve its products.

---

## বাংলা

### ১. Android Studio একবার সেট আপ (প্রায় ১০ মিনিট)

1. **Android Studio** খুলুন → **Settings → Plugins** → **Flutter** ইনস্টল করুন, তারপর রিস্টার্ট করুন।
2. **Settings → Languages & Frameworks → Flutter** → Flutter SDK path: `C:\src\flutter`
3. **Tools → SDK Manager → SDK Tools**:
   - **Show Package Details** টিক দিন।
   - **NDK (Side by side)**-এর ভেতরে **28.2.13676358** টিক দিন।
   - **Android SDK Command-line Tools** টিক দিন।
   - তারপর **Apply** চাপুন। NDK ছাড়া অ্যাপ বিল্ড হবে না।
4. PowerShell খুলে লাইসেন্স গ্রহণ করুন (পড়ে `y` চাপুন):
   ```
   C:\src\flutter\bin\flutter doctor --android-licenses
   ```
5. যাচাই: `C:\src\flutter\bin\flutter doctor`। **Android toolchain**-এ ✓ দেখাবে।

> ডাউনলোডে "certificate" বা "PKIX" ত্রুটি দেখালে অ্যান্টিভাইরাসের HTTPS স্ক্যানিং সাময়িক বন্ধ করুন, অথবা অন্য নেটওয়ার্ক ব্যবহার করুন।

### ২. ফোন যুক্ত করুন

1. ফোনে **Settings → About phone** → **Build number**-এ ৭ বার ট্যাপ করুন।
2. **Developer options** → **USB debugging** চালু করুন।
3. USB দিয়ে ফোন যুক্ত করুন এবং "Allow USB debugging?"-এ **Allow** চাপুন।

### ৩. কম্পিউটারে ব্যাকএন্ড চালু করুন

`factory-carbon` ফোল্ডারে PowerShell-এ চালান:

```
powershell -ExecutionPolicy Bypass -File .\start_backend.ps1
```

স্ক্রিনে **সার্ভারের ঠিকানা** (যেমন `192.168.1.20:8000`) ও **অ্যাপ টোকেন** দেখাবে। জানালাটি খোলা রাখুন।

- ফোন ও কম্পিউটার **একই Wi-Fi**-তে থাকতে হবে।
- Windows Firewall জিজ্ঞেস করলে **Private networks** অনুমতি দিন।

### ৪. অ্যাপ চালান

1. Android Studio → **File → Open** → `factory-carbon\app` ফোল্ডার নির্বাচন করুন।
2. **Factory Carbon (dev)** নির্বাচন করুন, ফোন বেছে নিন, ▶ **Run** চাপুন। প্রথমবার কয়েক মিনিট লাগবে।
3. অ্যাপে: **সেটিংস → সার্ভার সংযোগ**।
   - স্ক্রিপ্টে দেখানো ঠিকানা ও টোকেন লিখুন।
   - **সংযোগ পরীক্ষা করুন** চাপুন, তারপর **সংরক্ষণ** চাপুন।
4. ভাষা: প্রথম স্ক্রিন বা হোমের উপরের **বাংলা / English** বোতাম দিয়ে যেকোনো সময় বদলাতে পারবেন।

### ৫. বিল পড়া চালু করা (Gemini key পেলে)

`backend\.env` খুলে `GEMINI_API_KEY=`-এর পরে key বসান, সংরক্ষণ করুন এবং `start_backend.ps1` আবার চালান। ততক্ষণ "হাতে লিখুন" দিয়ে সব বিল যোগ করা যাবে।
