/// Admin hesabinin e-posta adresi. Bu hesapla giris yapildiginda
/// uygulama normal magaza yerine yonetici panelini acar.
const String kAdminEmail = 'admin@gmail.com';

/// Bir siparisin gecebilecegi durumlar (sirayla).
/// Yeni siparisler ilk durumda ("Onay Bekliyor") baslar; admin
/// bu listeyi izleyerek durumu ileri tasir.
const List<String> kOrderStatuses = <String>[
  'Onay Bekliyor',
  'Hazirlaniyor',
  'Kargoya Verildi',
  'Teslim Edildi',
];
