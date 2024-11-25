//
//  ProfileEditView.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/21/24.
//

import Kingfisher
import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var houseEntryOptionsVM: HouseEntryOptionsViewModel
    @State private var nickname: String = ""
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var isUsingDefaultImage: Bool = true
    
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
                        .font(.system(size: 15, weight: .regular))
                        .padding(.top)
                        .padding(.horizontal)
                    
                    TextField("nickname", text: $nickname)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                .padding(.bottom, 260)
                
                Button(action: {
                    updateProfile()
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
            .navigationDestination(isPresented: $profileVM.isProfiledIn) {
                HouseEntryOptionsView()
            }
        }
        .alert("프로필 설정 확인", isPresented: $profileVM.isProfileShowing) {
            Button("확인") {
                profileVM.isProfileShowing = false
                if !profileVM.isProfiledError {
                            profileVM.isProfiledIn = true
                        }
            }
        } message: {
            Text(profileVM.message)
        }
    }
    
    private func updateProfile() {
        let photo: UIImage?
        if isUsingDefaultImage {
            photo = UIImage(named: defaultImageName)
        } else {
            photo = selectedImage
        }

        print("Profile edit started.")
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
