import Kingfisher
import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @StateObject var houseEntryOptionsVM = HouseEntryOptionsViewModel()
    @State private var nickname: String = UserDefaults.standard.string(forKey: "nickname") ?? ""
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var isUsingDefaultImage: Bool = false
    @State private var photoURL: URL?
    
    let defaultImageName = "round-profile"
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 180, height: 180)
                            .clipShape(Circle())
                    } else if let photoURLString = UserDefaults.standard.string(forKey: "photo") {
                        // URL 생성
                        if let photoURL = URL(string: "\(APIEndpoints.blobURL)/\(photoURLString)") {
                            KFImage(photoURL)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 180, height: 180)
                                .clipShape(Circle())
                        } else {
                            Image(defaultImageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 180, height: 180)
                                .clipShape(Circle())
                        }
                    } else {
                        Image(defaultImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 180, height: 180)
                            .clipShape(Circle())
                    }
                    
                    Image(systemName: "pencil.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color(red: 33/255, green: 174/255, blue: 225/255)))
                        .clipShape(Circle())
                        .offset(x: 60, y: 60)
                }
                .onTapGesture {
                    showActionSheet = true
                }
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
                
                VStack(alignment: .leading) {
                    Text("별명으로 사용할 이름을 입력하세요")
                        .foregroundColor(Color.gray)
                        .padding(.top)
                        .font(.headline)
                    CustomTextField(icon: "", placeholder: "nickname", text: $nickname)
                }
                .padding(.bottom, 260)

                NavigationLink(
                    destination: HouseEntryOptionsView(),
                    isActive: $profileVM.isNavigatingToEntry
                ) {
                    Button(action: {
                        updateProfile()
                        houseEntryOptionsVM.createHouse()
                    }) {
                        Text("완료")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .alert("프로필 설정 확인", isPresented: $profileVM.isProfileShowing) {
                Button("확인") {
                    print(profileVM.isProfiledError)
                    print(profileVM.isNavigatingToEntry)
                    DispatchQueue.main.async {
                        if !profileVM.isProfiledError {
                            profileVM.isNavigatingToEntry = true
                        }
                        profileVM.isProfileShowing = false
                    }
                }
            } message: {
                Text(profileVM.message)
            }
        }
    }

    private func updateProfile() {
        var photo: UIImage? = nil
        var savePhoto: String?

        if let savedPhotoURLString = UserDefaults.standard.string(forKey: "photo") {
            // 저장된 이미지 파일 이름을 그대로 사용
            savePhoto = savedPhotoURLString // photo1732720416850.jpg
            print("nickname \(nickname), photo \(savePhoto!)")
            return profileVM.profileEdit(nickname: nickname, photoURL: savePhoto!) // 파일 이름만 전달
        } else if let selectedImage = selectedImage {
            // 사용자 선택 이미지가 있다면 해당 이미지를 사용
            photo = selectedImage
        } else if isUsingDefaultImage {
            // 기본 이미지로 설정된 경우 기본 이미지를 UIImage로 설정
            if let defaultImage = UIImage(named: defaultImageName) {
                photo = defaultImage
            }
        }

        print("Profile edit started.")
        print("nickname \(nickname), photo \(photo)")
        profileVM.profileEdit(nickname: nickname, photo: photo)
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

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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
