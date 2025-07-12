# Download Original Jameel Noori Nastaleeq Font

## Steps to restore the original large font:

### Method 1: Direct Download
1. Visit: https://www.urdufont.org/download.php?id=737833
2. Complete the captcha verification
3. Download `JameelNooriNastaleeq.ttf` (≈10-11MB)
4. Place in `assets/fonts/JameelNooriNastaleeq.ttf`

### Method 2: Alternative Sources
1. Search for "Jameel Noori Nastaleeq original" on:
   - https://urdufonts.net/
   - https://www.pakfonts.com/
   - https://fonts.google.com/noto/specimen/Noto+Nastaliq+Urdu

### Method 3: If you have the old app backup
1. Look in your old project backup
2. Copy `assets/fonts/JameelNooriNastaleeq.ttf` from there

## After downloading:

1. **Replace current font**:
   ```bash
   # Remove current smaller font
   rm assets/fonts/Jameel-Noori-Nastaleeq-Regular.ttf
   
   # Add the large font
   cp /path/to/downloaded/JameelNooriNastaleeq.ttf assets/fonts/
   ```

2. **Update pubspec.yaml**:
   ```yaml
   assets:
     - assets/fonts/JameelNooriNastaleeq.ttf  # Original large font
     - assets/fonts/NotoNastaliqUrdu-Regular.ttf
   
   fonts:
     - family: JameelNooriNastaleeq
       fonts:
         - asset: assets/fonts/JameelNooriNastaleeq.ttf
           weight: 400
   ```

3. **Run**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Expected Results:
- **App size**: Will increase by ~10MB
- **Font quality**: Original authentic Jameel Noori appearance
- **Bismillah text**: Will look exactly as before with proper proportions

## Note:
This reverses our size optimization for fonts but gives you the exact original appearance you want. 