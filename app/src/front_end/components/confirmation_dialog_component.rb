class ConfirmationDialogComponent < AppComponent
  def view_template
    brut_confirmation_dialog(show_warnings: true) do
      dialog(class:"ba bw-2 bc-gray-600 br-2 shadow-4 bg-red-900 pa-3") do
        div(class:"flex flex-column items-center justify-between gap-3 bg-purple") do
          h1(class:"f-4 fw-5 lh-title measure-narrow mh-auto")
          nav(class: "flex justify-between w-100 items-center gap-3") do
            render ButtonComponent.new(size: "small", color: "orange", label: t(:nevermind), value: "cancel", icon: "close-line-icon")
            render ButtonComponent.new(size: "normal", color: "blue", label: "", value: "ok" )
          end
        end
      end
    end
  end
end
