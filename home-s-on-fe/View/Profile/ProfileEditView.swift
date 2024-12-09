import Kingfisher
import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @StateObject var houseEntryOptionsVM = HouseEntryOptionsViewModel()
    @State private var nickname: String = UserDefaults.standard.string(forKey: "nickname") ?? ""
    @State private var photo: String = UserDefaults.standard.string(forKey: "photo") ?? ""
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var isUsingDefaultImage: Bool = false
    @State private var photoURL: URL?
    @State private var navigateToHouseEntry = false
    
    let defaultImageName = "default-round-profile"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    profileImageSection
                    nicknameSection
                    Spacer()
                    completeButton
                }
                .padding()
            }
            .navigationBarTitle("프로필 수정", displayMode: .inline)
            .alert("프로필 설정 확인", isPresented: $profileVM.isProfileShowing) {
                Button("확인") {
                    if !profileVM.isProfiledError {
                        navigateToHouseEntry = true
                    }
                    profileVM.isProfileShowing = false
                }
            } message: {
                Text(profileVM.message)
            }
            .fullScreenCover(isPresented: $navigateToHouseEntry, content: {
                HouseEntryOptionsView()
            })
        }
    }
    
    private var profileImageSection: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 210, height: 210)
                .shadow(color: Color.gray.opacity(0.2), radius: 8, x: 0, y: 4)
            
            if isUsingDefaultImage {
                Image(defaultImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .clipShape(Circle())
            } else if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
            } else {
                Image("round-profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 180, height: 180)
                    .clipShape(Circle())
            }
        }
        .frame(width: 220, height: 220)
        .onTapGesture { showActionSheet = true }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(title: Text("프로필 이미지 선택"), buttons: [
                .default(Text("앨범에서 선택")) {
                    showImagePicker = true
                    isUsingDefaultImage = false
                },
                .default(Text("기본 이미지로 설정")) {
                    selectedImage = nil
                    isUsingDefaultImage = true
                },
                .cancel()
            ])
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    private var nicknameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("별명으로 사용할 이름을 입력하세요")
                .font(.headline)
                .foregroundColor(Color.mainColor) // ColorExtension에서 정의한 mainColor 사용
            
            TextField("별명", text: $nickname)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.mainColor.opacity(0.3), lineWidth: 1))
                .padding(.horizontal, 5)
        }
    }
    
    private var completeButton: some View {
        Button(action: {
            updateProfile {
                houseEntryOptionsVM.createHouse()
            }
        }) {
            Text("완료")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.mainColor) // ColorExtension에서 정의한 mainColor 사용
                .cornerRadius(10)
                .shadow(color: Color.mainColor.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
    
    private func updateProfile(completion: @escaping () -> Void) {
        let photo: UIImage?
        if isUsingDefaultImage {
            photo = UIImage(named: defaultImageName)
        } else {
            photo = selectedImage
        }
        
        profileVM.profileEdit(nickname: nickname, photo: photo) { success in
            if success {
                completion()
            } else {
                profileVM.isProfileShowing = true
                print("Profile update failed.")
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    let profileVM = ProfileViewModel()
    let homeEntryOptionsVM = HouseEntryOptionsViewModel()
    
    ProfileEditView()
        .environmentObject(profileVM)
        .environmentObject(homeEntryOptionsVM)
}
