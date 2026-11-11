import SwiftUI

struct SavedSetEditor:View {
    @EnvironmentObject var store:AppStore
    @Environment(\.dismiss) var dismiss
    var sessionID:UUID
    @State var item:WorkoutExercise
    @State private var remove=false
    @State private var error=false
    @FocusState private var editing:Bool
    var existing:Bool {store.data.history.first{$0.id==sessionID}?.exercises.contains{$0.id==item.id} == true}
    var body:some View {
        VStack(spacing:16) {
            SheetTitle(title:item.exercise.name)
            ScrollView {
                VStack(spacing:18) {
                    HStack {ExerciseThumb(exercise:item.exercise,size:70);Text("\(store.t("Sửa các set đã ghi","Edit logged sets"))").font(.dopa(size:20,weight:.semibold));Spacer()}
                    HStack {Text("SET").frame(width:32);Text(item.exercise.timed ? store.t("GIÂY","SECONDS"):store.t("SỐ LẦN","REPS")).frame(maxWidth:.infinity);Text(store.t("TẠ","WEIGHT")+" (\(store.unit))").frame(maxWidth:.infinity);Color.clear.frame(width:35,height:1)}.font(.dopa(size:11,weight:.semibold)).foregroundStyle(Dopa.muted)
                    ForEach(item.sets.indices,id:\.self) { index in
                        HStack(spacing:12) {
                            Text(item.sets[index].warmup ? "W":"\(index+1)").frame(width:32).foregroundStyle(Dopa.muted)
                            TextField(item.exercise.timed ? "Giây":"Số lần",value:Binding(get:{item.exercise.timed ? item.sets[index].seconds:item.sets[index].reps},set:{v in if item.exercise.timed{item.sets[index].seconds=v;item.sets[index].reps=0}else{item.sets[index].reps=v}}),format:.number).keyboardType(.numberPad).focused($editing).padding(14).background(Dopa.raised).clipShape(RoundedRectangle(cornerRadius:10))
                            TextField("Tạ",value:Binding(get:{store.displayWeight(item.sets[index].weight)},set:{item.sets[index].weight=store.kilograms($0)}),format:.number.precision(.fractionLength(0...2))).keyboardType(.decimalPad).focused($editing).padding(14).background(Dopa.raised).clipShape(RoundedRectangle(cornerRadius:10))
                            Button{item.sets.remove(at:index)}label:{Image(systemName:"minus.circle").foregroundStyle(.red).frame(width:35,height:44)}.accessibilityLabel("Xóa set \(index+1)")
                        }.contextMenu {Button(item.sets[index].warmup ? "Set chính":"Set khởi động"){item.sets[index].warmup.toggle()}}
                    }
                    Button{var set=item.sets.last ?? LoggedSet(reps:item.exercise.defaultReps,weight:item.exercise.defaultWeight);set.id=UUID();set.completed=true;item.sets.append(set)}label:{Label("Thêm set",systemImage:"plus").frame(maxWidth:.infinity,alignment:.leading).padding(16).foregroundStyle(Dopa.lime)}
                    if !item.exercise.convention.isEmpty {Text(item.exercise.convention).font(.footnote).foregroundStyle(Dopa.muted)}
                    if existing {Button("Xóa bài khỏi buổi tập",role:.destructive){remove=true}.frame(maxWidth:.infinity).padding(16)}
                }.padding(.horizontal,20)
            }.scrollDismissesKeyboard(.interactively)
            DopaButton(title:"Lưu thay đổi",enabled:!item.sets.isEmpty) {editing=false;if store.saveHistoryExercise(sessionID:sessionID,item:item){dismiss()}else{error=true}}.padding(20)
        }.background(Dopa.background).presentationDragIndicator(.visible)
            .alert("Kiểm tra set",isPresented:$error){Button("Đóng",role:.cancel){}}message:{Text("Mỗi set cần số lần hoặc số giây lớn hơn 0 và mức tạ hợp lệ. Bài trọng lượng cơ thể có thể để 0 kg.")}
            .alert("Xóa bài khỏi buổi đã lưu?",isPresented:$remove){Button("Xóa",role:.destructive){store.removeHistoryExercise(sessionID:sessionID,exerciseID:item.id);dismiss()};Button("Hủy",role:.cancel){}}
    }
}
