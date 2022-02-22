import SwiftUI
import Core

struct ImportCardView: View {
    let item: ArchiveItem

    @Environment(\.colorScheme) var colorScheme

    var backgroundColor: Color {
        colorScheme == .dark
            ? .secondaryBackgroundDark
            : .secondaryBackgroundLight
    }

    var cardShadowColor: Color {
        colorScheme == .dark
            ? .shadowDark
            : .shadowLight
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 0) {
                    item.icon
                        .renderingMode(.template)
                        .padding(8)

                    Text(item.kind)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.trailing, 12)
                }
                .foregroundColor(.black)
                .background(Color.keyYellow)
                .cornerRadius(18, corners: [.bottomRight])

                Spacer()
            }

            VStack(alignment: .leading, spacing: 14) {
                Text(item.name.value)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)

                if item.description.isEmpty {
                    Text("Note is empty")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black30)
                        .italic()
                } else {
                    Text(item.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black30)
                        .lineLimit(1)
                }
            }
            .padding(.top, 21)
            .padding(.horizontal, 12)

            Divider()
                .padding(.top, 18)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Key Type:")
                        .foregroundColor(.black30)

                    Text("EM-Marin")
                }

                HStack {
                    Text("Data:")
                        .foregroundColor(.black30)

                    Text("DC 69 66 0F 12")
                }
            }
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 18)
        }
        .background(backgroundColor)
        .cornerRadius(16)
        .shadow(color: cardShadowColor, radius: 16, x: 0, y: 4)
    }
}

extension ArchiveItem {
    var description: String {
        ""
    }
}

extension ArchiveItem {
    var kind: String {
        switch self.fileType {
        case .rfid: return "RFID 125"
        case .subghz: return "Sub-GHz"
        case .nfc: return "NFC"
        case .ibutton: return "iButton"
        case .irda: return "Infrared"
        }
    }
}
