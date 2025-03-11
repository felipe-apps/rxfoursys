# Define a versão mínima do iOS para evitar problemas de compatibilidade
platform :ios, '12.0'

target 'RxFoursys' do
  use_frameworks!

  # Dependências principais do projeto
  pod 'RxSwift', '~> 6.5'
  pod 'RxCocoa', '~> 6.5'
  
  # Firebase Auth e Firestore
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Core'

  target 'RxFoursysTests' do
    inherit! :search_paths
  end

  target 'RxFoursysUITests' do
    inherit! :search_paths
  end
end
