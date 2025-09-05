import '../models/ruler_model.dart';

class RulerData {
  static const Map<String, dynamic> _rawData = {
    'thong_thuy': {
      'name': 'Thước Lỗ Ban 52.2cm: Khoảng thông thủy (cửa, cửa sổ...)',
      'title_short': 'Thước Lỗ Ban 52.2cm',
      'description_title': 'Khoảng không thông thủy (cửa, cửa sổ...)',
      'total_length': 52.2,
      'khoang': [
        {
          'name': 'Quý nhân',
          'type': 'good',
          'cung': [
            {'name': 'Quyền lộc', 'desc': 'May mắn về tài lộc, chức vụ, gia đình thịnh vượng.'},
            {'name': 'Trung tín', 'desc': 'Gia chủ trung thực, được mọi người tín nhiệm.'},
            {'name': 'Tác quan', 'desc': 'Có đường công danh, sự nghiệp rộng mở.'},
            {'name': 'Phát đạt', 'desc': 'Làm ăn phát đạt, kinh doanh thuận lợi.'},
            {'name': 'Thông minh', 'desc': 'Con cái thông minh, học giỏi, thành tài.'},
          ]
        },
        {
          'name': 'Hiểm họa',
          'type': 'bad',
          'cung': [
            {'name': 'Án thành', 'desc': 'Dễ vướng vào kiện tụng, tranh chấp.'},
            {'name': 'Hỗn nhân', 'desc': 'Gia đình bất hòa, tình cảm vợ chồng rạn nứt.'},
            {'name': 'Thất hiếu', 'desc': 'Con cái ngỗ nghịch, không vâng lời cha mẹ.'},
            {'name': 'Tai họa', 'desc': 'Gặp phải những tai ương bất ngờ, khó lường.'},
            {'name': 'Trường bệnh', 'desc': 'Sức khỏe suy yếu, bệnh tật kéo dài.'},
          ]
        },
        {
          'name': 'Thiên tai',
          'type': 'bad',
          'cung': [
            {'name': 'Hoàn tử', 'desc': 'Nguy cơ mất người, tuyệt tự.'},
            {'name': 'Quan tài', 'desc': 'Gặp chuyện xui xẻo, tang tóc.'},
            {'name': 'Thân tàn', 'desc': 'Bản thân có thể gặp tai nạn, thương tật.'},
            {'name': 'Thất tài', 'desc': 'Hao tốn tiền của, tài sản tiêu tán.'},
            {'name': 'Hệ quả', 'desc': 'Gánh chịu hậu quả xấu từ những việc đã làm.'},
          ]
        },
        {
          'name': 'Thiên tài',
          'type': 'good',
          'cung': [
            {'name': 'Thi thơ', 'desc': 'Gia chủ có tài năng về nghệ thuật, văn chương.'},
            {'name': 'Văn học', 'desc': 'Đường học vấn, thi cử thuận lợi.'},
            {'name': 'Thanh quý', 'desc': 'Được mọi người kính trọng, có danh tiếng tốt.'},
            {'name': 'Tác lộc', 'desc': 'Được hưởng phúc lộc trời ban, may mắn về tiền bạc.'},
            {'name': 'Thiên lộc', 'desc': 'Tài lộc bất ngờ, có của ăn của để.'},
          ]
        },
        {
          'name': 'Nhân lộc',
          'type': 'good',
          'cung': [
            {'name': 'Trí tồn', 'desc': 'Trí tuệ được bảo tồn, sáng suốt trong mọi việc.'},
            {'name': 'Phú quý', 'desc': 'Giàu có và địa vị cao, được kính trọng.'},
            {'name': 'Tiến bửu', 'desc': 'Được tặng những vật quý giá, tài sản gia tăng.'},
            {'name': 'Thập thiện', 'desc': 'Làm nhiều việc thiện, được báo ơn tốt lành.'},
            {'name': 'Văn chương', 'desc': 'Có tài văn chương, học vấn cao.'},
          ]
        },
        {
          'name': 'Cô độc', 
          'type': 'bad',
          'cung': [
            {'name': 'Bạc nghịch', 'desc': 'Bạc bẽo, nghịch lý, khó gần gũi mọi người.'},
            {'name': 'Vô vọng', 'desc': 'Không có hy vọng, thất vọng trong cuộc sống.'},
            {'name': 'Ly tán', 'desc': 'Gia đình ly tán, xa cách nhau.'},
            {'name': 'Tửu thục', 'desc': 'Nghiện rượu chè, sa đọa trong ăn chơi.'},
            {'name': 'Dâm dục', 'desc': 'Sa đọa vào lạc thú, hư hỏng đạo đức.'},
          ]
        },
        {
          'name': 'Thiên tặc',
          'type': 'bad', 
          'cung': [
            {'name': 'Phong bệnh', 'desc': 'Mắc bệnh về gió, thấp khớp khó chữa.'},
            {'name': 'Chiêu ôn', 'desc': 'Dễ mắc bệnh dịch, nhiễm trùng.'},
            {'name': 'Ồn tài', 'desc': 'Tiền bạc khó kiếm, thu nhập bấp bênh.'},
            {'name': 'Ngục tù', 'desc': 'Có nguy cơ vào tù, bị giam cầm.'},
            {'name': 'Quang tài', 'desc': 'Tài sản tiêu tan, không giữ được của cải.'},
          ]
        },
        {
          'name': 'Tể tướng',
          'type': 'good',
          'cung': [
            {'name': 'Đại tài', 'desc': 'Có tài năng lớn, khả năng phi thường.'},
            {'name': 'Thi thơ', 'desc': 'Tài năng về văn chương, thơ ca.'},
            {'name': 'Hoạch tài', 'desc': 'Kiếm được nhiều tiền, tài chính dồi dào.'},
            {'name': 'Hiểu tử', 'desc': 'Con cái hiếu thảo, biết kính trọng cha mẹ.'},
            {'name': 'Quý nhân', 'desc': 'Gặp được quý nhân phù trợ, giúp đỡ.'},
          ]
        },
      ]
    },
    'duong_trach': {
      'name': 'Thước Lỗ Ban 42.9cm (Dương trạch): Khối xây dựng (bếp, bệ, bậc...)',
      'title_short': 'Thước Lỗ Ban 42.9cm (Dương trạch)',
      'description_title': 'Khối xây dựng (bếp, bệ, bậc...)',
      'total_length': 42.9,
      'khoang': [
        {
          'name': 'Tài',
          'type': 'good',
          'cung': [
            {'name': 'Tài đức', 'desc': 'Có tài và có đức, được phúc lộc.'},
            {'name': 'Bảo khố', 'desc': 'Có kho báu, làm ăn tích lũy được nhiều của cải.'},
            {'name': 'Lục hợp', 'desc': 'Gặp nhiều may mắn, quan hệ thuận hòa.'},
            {'name': 'Nghênh phúc', 'desc': 'Đón nhận phúc lộc, những điều tốt lành.'},
          ]
        },
        {
          'name': 'Bệnh',
          'type': 'bad',
          'cung': [
            {'name': 'Thoát tài', 'desc': 'Mất mát tiền của, không giữ được tài sản.'},
            {'name': 'Công sự', 'desc': 'Dễ gặp rắc rối liên quan đến pháp luật, kiện tụng.'},
            {'name': 'Lao chấp', 'desc': 'Vướng vào vòng lao lý, tù tội.'},
            {'name': 'Cô quả', 'desc': 'Cuộc sống cô đơn, lẻ loi.'},
          ]
        },
        {
          'name': 'Ly',
          'type': 'bad',
          'cung': [
            {'name': 'Trường bệnh', 'desc': 'Bệnh tật triền miên, sức khỏe kém.'},
            {'name': 'Kiếp tài', 'desc': 'Bị cướp đoạt tài sản, tiền bạc.'},
            {'name': 'Quan quỷ', 'desc': 'Gặp chuyện không may liên quan đến chính quyền.'},
            {'name': 'Thất thoát', 'desc': 'Mất mát, thất lạc tài sản, đồ đạc.'},
          ]
        },
        {
          'name': 'Nghĩa',
          'type': 'good',
          'cung': [
            {'name': 'Thêm đinh', 'desc': 'Gia đình có thêm con trai, người nối dõi.'},
            {'name': 'Ích lợi', 'desc': 'Làm việc gì cũng có lợi, thu được kết quả tốt.'},
            {'name': 'Quý tử', 'desc': 'Sinh được con trai quý, thông minh, hiếu thảo.'},
            {'name': 'Đại cát', 'desc': 'Rất may mắn, mọi sự hanh thông.'},
          ]
        },
        {
          'name': 'Quan',
          'type': 'good',
          'cung': [
            {'name': 'Thuận khoa', 'desc': 'Thi cử thuận lợi, đỗ đạt cao.'},
            {'name': 'Hoạch tài', 'desc': 'Kiếm được nhiều tiền, tài chính phát đạt.'},
            {'name': 'Tấn đức', 'desc': 'Đức hạnh ngày càng cao, được kính trọng.'},
            {'name': 'Phú quý', 'desc': 'Giàu có và có địa vị cao trong xã hội.'},
          ]
        },
        {
          'name': 'Kiếp',
          'type': 'bad',
          'cung': [
            {'name': 'Tử biệt', 'desc': 'Chia ly sinh tử, tang thương trong gia đình.'},
            {'name': 'Khoái khẩu', 'desc': 'Hay cãi vã, miệng lưỡi bất hòa.'},
            {'name': 'Ly hương', 'desc': 'Phải xa quê hương, sống nơi đất khách.'},
            {'name': 'Tấn tài', 'desc': 'Dù có tiền cũng không giữ lâu, tiêu tán nhanh.'},
          ]
        },
        {
          'name': 'Hại',
          'type': 'bad',
          'cung': [
            {'name': 'Tai chi', 'desc': 'Gặp nhiều tai họa, chuyện không may.'},
            {'name': 'Tử tuyệt', 'desc': 'Nguy cơ tử vong, tuyệt tự của dòng họ.'},
            {'name': 'Bệnh lâm', 'desc': 'Bệnh tật kéo dài, sức khỏe yếu kém.'},
            {'name': 'Khẩu thiệt', 'desc': 'Lời nói gây tổn hại, tranh cãi miệng lưỡi.'},
          ]
        },
        {
          'name': 'Bản',
          'type': 'good',
          'cung': [
            {'name': 'Tai chí', 'desc': 'Mặc dù có khó khăn nhưng cuối cùng vẫn may mắn.'},
            {'name': 'Đăng khoa', 'desc': 'Thi cử đỗ đạt, có thành tích học tập tốt.'},
            {'name': 'Tiến bảo', 'desc': 'Tài sản gia tăng, có nhiều của cải quý giá.'},
            {'name': 'Hưng vượng', 'desc': 'Gia đình hưng thịnh, phát triển vượng mạnh.'},
          ]
        },
      ]
    },
    'am_trach': {
      'name': 'Thước Lỗ Ban 38.8cm (Âm phần): Đồ nội thất (bàn thờ, tủ...)',
      'title_short': 'Thước Lỗ Ban 38.8cm (Âm phần)',
      'description_title': 'Đồ nội thất (bàn thờ, tủ...)',
      'total_length': 38.8,
      'khoang': [
        {
          'name': 'Đinh',
          'type': 'good',
          'cung': [
            {'name': 'Phúc Tinh', 'desc': 'Sao phúc chiếu, mang lại may mắn, bình an.'},
            {'name': 'Đỗ Đạt', 'desc': 'Thi cử đỗ đạt, công danh thăng tiến.'},
            {'name': 'Tài Vượng', 'desc': 'Tài lộc dồi dào, tiền bạc thịnh vượng.'},
            {'name': 'Đăng Khoa', 'desc': 'Đỗ đạt cao, có tên trên bảng vàng.'},
          ]
        },
        {
          'name': 'Hại',
          'type': 'bad',
          'cung': [
            {'name': 'Khẩu thiệt', 'desc': 'Gặp chuyện thị phi, tai tiếng, tranh cãi.'},
            {'name': 'Lâm bệnh', 'desc': 'Mắc bệnh tật, sức khỏe suy yếu.'},
            {'name': 'Tử tuyệt', 'desc': 'Đoạn tuyệt đường con cái, không có người nối dõi.'},
            {'name': 'Tai chí', 'desc': 'Tai họa bất ngờ ập đến.'},
          ]
        },
        {
          'name': 'Vượng',
          'type': 'good',
          'cung': [
            {'name': 'Thiên đức', 'desc': 'Được trời đất che chở, có đức độ.'},
            {'name': 'Hỷ sự', 'desc': 'Trong nhà có chuyện vui, hỷ tín.'},
            {'name': 'Tiến bảo', 'desc': 'Có của cải, tài lộc đến nhà.'},
            {'name': 'Nạp phúc', 'desc': 'Đón nhận phúc đức, may mắn.'},
          ]
        },
        {
          'name': 'Khổ',
          'type': 'bad',
          'cung': [
            {'name': 'Thất thoát', 'desc': 'Tài sản thất thoát, mất mát liên tục.'},
            {'name': 'Quan quỷ', 'desc': 'Vướng vào chuyện pháp luật, tranh tụng.'},
            {'name': 'Kiếp tài', 'desc': 'Tài sản bị cướp đoạt, mất trộm.'},
            {'name': 'Vô tự', 'desc': 'Không có con cái, tuyệt tự dòng họ.'},
          ]
        },
        {
          'name': 'Nghĩa',
          'type': 'good',
          'cung': [
            {'name': 'Đại cát', 'desc': 'Đại cát đại lợi, mọi việc hanh thông.'},
            {'name': 'Tài vượng', 'desc': 'Tài chính phát đạt, giàu có thịnh vượng.'},
            {'name': 'Ích lợi', 'desc': 'Có lợi trong mọi việc làm.'},
            {'name': 'Thiên khố', 'desc': 'Có kho tàng trời ban, của cải dồi dào.'},
          ]
        },
        {
          'name': 'Quan',
          'type': 'good',
          'cung': [
            {'name': 'Phú quý', 'desc': 'Giàu sang phú quý, địa vị cao.'},
            {'name': 'Tiến bảo', 'desc': 'Tài lộc tiến vào, của cải gia tăng.'},
            {'name': 'Hoạch tài', 'desc': 'Kiếm được nhiều tiền, thu nhập cao.'},
            {'name': 'Thuận khoa', 'desc': 'Học hành thuận lợi, thi cử đỗ đạt.'},
          ]
        },
        {
          'name': 'Tử',
          'type': 'bad',
          'cung': [
            {'name': 'Ly hương', 'desc': 'Xa lìa quê hương, sống nơi đất khách.'},
            {'name': 'Tử biệt', 'desc': 'Chia ly sinh tử, tang thương.'},
            {'name': 'Thoát đinh', 'desc': 'Mất đi người nam trong gia đình.'},
            {'name': 'Thất tài', 'desc': 'Thất thoát tài sản, tiền bạc.'},
          ]
        },
        {
          'name': 'Hưng',
          'type': 'good',
          'cung': [
            {'name': 'Đông khoa', 'desc': 'Thi cử đỗ đạt, thành danh.'},
            {'name': 'Quý tử', 'desc': 'Sinh được con trai quý, thông minh.'},
            {'name': 'Thêm đinh', 'desc': 'Gia tăng dân số, có thêm con cái.'},
            {'name': 'Hưng vượng', 'desc': 'Gia đình hưng thịnh, phát triển mạnh.'},
          ]
        },
        {
          'name': 'Thất',
          'type': 'bad',
          'cung': [
            {'name': 'Cô quả', 'desc': 'Sống cô độc, không có người thân.'},
            {'name': 'Lao chấp', 'desc': 'Vướng vào lao lý, tù tội.'},
            {'name': 'Công sự', 'desc': 'Công việc gặp trở ngại, khó khăn.'},
            {'name': 'Thoát tài', 'desc': 'Tiền bạc tiêu tán, không giữ được.'},
          ]
        },
        {
          'name': 'Tài',
          'type': 'good',
          'cung': [
            {'name': 'Nghênh phúc', 'desc': 'Đón nhận phúc lành, may mắn.'},
            {'name': 'Lục hợp', 'desc': 'Mọi việc hòa hợp, thuận lợi.'},
            {'name': 'Tiến bảo', 'desc': 'Tiến tài tiến lộc, giàu có.'},
            {'name': 'Tài đức', 'desc': 'Vừa có tài vừa có đức, hoàn hảo.'},
          ]
        },
      ]
    },
  };

  static Map<RulerType, RulerModel> getAllRulers() {
    return {
      RulerType.thongThuy: RulerModel.fromJson(_rawData['thong_thuy']!, RulerType.thongThuy),
      RulerType.duongTrach: RulerModel.fromJson(_rawData['duong_trach']!, RulerType.duongTrach),
      RulerType.amTrach: RulerModel.fromJson(_rawData['am_trach']!, RulerType.amTrach),
    };
  }

  static RulerModel getRuler(RulerType type) {
    final rulers = getAllRulers();
    return rulers[type]!;
  }

  static List<RulerModel> getAllRulersList() {
    return getAllRulers().values.toList();
  }
}