import SwiftUI

struct KnowledgeQuestionView: View {
    let questionsText: String
    let answers: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Text("Knowledge Questions")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
                .padding()
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(zip(questionsText.components(separatedBy: .newlines).filter { $0.hasPrefix("Q: ") }, answers)), id: \.0) { question, answer in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(question)
                                .font(.title3)
                                .foregroundColor(.primary)
                            
                            Text("A: \(answer)")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
        }
    }
} 