class DummyData {
  static List<Map<String, dynamic>> getStudents() {
    return [
      {
        'id': 1,
        'name': 'Ahmad Fauzi',
        'className': 'XI IPA 1',
        'photoPath': null,
        'sortOrder': 0,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 2,
        'name': 'Budi Santoso',
        'className': 'XI IPA 1',
        'photoPath': null,
        'sortOrder': 1,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 3,
        'name': 'Cindy Permata',
        'className': 'XI IPA 1',
        'photoPath': null,
        'sortOrder': 2,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 4,
        'name': 'Denny Pradana',
        'className': 'XI IPA 2',
        'photoPath': null,
        'sortOrder': 0,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 5,
        'name': 'Eka Putri',
        'className': 'XI IPA 2',
        'photoPath': null,
        'sortOrder': 1,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 6,
        'name': 'Farhan Ahmad',
        'className': 'XI IPA 2',
        'photoPath': null,
        'sortOrder': 2,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 7,
        'name': 'Gita Nirmala',
        'className': 'XI IPS 1',
        'photoPath': null,
        'sortOrder': 0,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 8,
        'name': 'Hadi Prasetyo',
        'className': 'XI IPS 1',
        'photoPath': null,
        'sortOrder': 1,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];
  }

  static Map<String, dynamic> getTeacher() {
    return {
      'id': 1,
      'name': 'Bapak Agus Supriyanto, S.Pd.',
      'className': 'XI IPA 1',
      'pin': '123456',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}