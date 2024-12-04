import Kingfisher
import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    //    @EnvironmentObject var houseEntryOptionsVM: HouseEntryOptionsViewModel
    @StateObject var houseEntryOptionsVM = HouseEntryOptionsViewModel()
    @State private var nickname: String = UserDefaults.standard.string(forKey: "nickname") ?? ""
    @State private var photo: String = UserDefaults.standard.string(forKey: "photo") ?? ""
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var isUsingDefaultImage: Bool = true
    @State private var photoURL: URL?
    @State private var navigateToHouseEntry = false
    
    let defaultImageName = "round-profile"
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    let photoURLString = photo
                    if !photoURLString.isEmpty, let photoURL = URL(string: "\(APIEndpoints.blobURL)/\(photoURLString)") {
                        KFImage(photoURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 180, height: 180)
                            .clipShape(Circle())
                        
                    } else {
                        RoundImage(image: UIImage(named: "round-profile")!, width: .constant(180.0), height: .constant(180.0))
                    }
                    
                    RoundImage(image: UIImage(systemName: "pencil.circle")!, width: .constant(50.0), height: .constant(50.0))
                        .background(Circle().fill(Color(red: 33/255, green: 174/255, blue: 225/255)).frame(width: 50, height: 55))
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
                .padding(.horizontal)
                .padding(.bottom, 260)
                
                Button(action: {
                    updateProfile {
                        houseEntryOptionsVM.createHouse()
                    }
                }) {
                    Text("완료")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
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
                print("Profile update failed.")
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
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let uiImage = info[.originalImage] as? UIImage {
                    parent.image = uiImage
                }
                picker.dismiss(animated: true)
            }
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
