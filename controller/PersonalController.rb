# encoding: utf-8
# Personal Controller
require_relative '../util/HtmlUtil'
require_relative '../model/CgiUser'

class PersonalController
  def index session,args
    isRedirect = false
    redirectLoc = ""
    # 更新用セッション値のクリア
    session[HtmlUtil::TEMPPASS] = ""
    session[HtmlUtil::TEMPNAME] = ""
    session[HtmlUtil::TEMPUID]  = ""

    uid = session[HtmlUtil::LOGINID]

    actionUrl = HtmlUtil.createUrl HtmlUtil::PersonCtrlName,"confirm"
    menuUrl = HtmlUtil.getMenuUrl

    name,isadmin = CgiUser.getUser uid

    form = <<-HTML
    <p><h2>ユーザ情報管理</h2></p>
    <form action="#{actionUrl}" method="post" accept-charset="UTF-8"
          autocomplete="off" name="personaldata">
      <table>
        <tbody>
          <tr>
            <th>名前</th>
            <td>
              <input type="text" name="name" size="20"
                     maxlength="#{CgiUser::NAMELENGTH}"
                     value="#{name}" autocomplete="off">
              <input type="hidden" name="curname" value="#{name}">
            </td>
          </tr>
          <tr>
            <th>ログインID</th>
            <td>
              <input type="text" name="uid" size="10"
                     maxlength="#{CgiUser::UIDLENGTH}"
                     value="#{uid}" autocomplete="off">
              <input type="hidden" name="curuid" value="#{uid}">
            </td>
          </tr>
          <tr>
            <th>パスワード</th>
            <td>
              <details>
                <summary>パスワードを変更する場合はこちらを展開してください
                </summary>
                <ul>
                  <li>現在のパスワード
                    <input type="password" name="curpass"
                           size="10" autocomplete="off">
                  </li>
                  <li>新しいパスワード
                    <input type="password" name="newpass"
                           size="10" autocomplete="off">
                  </li>
                  <li>新しいパスワード(確認)
                    <input type="password" name="confpass"
                           size="10" autocomplete="off">
                  </li>
                </ul>
              </details>
            </td>
          </tr>
        </tbody>
      </table>
      <input type="submit" value="確認">
    </form>
    <a href="#{menuUrl}">メニュー画面へ</a>
    HTML

    return form,isRedirect,redirectLoc
  end

  def confirm session,args
    isRedirect = false
    redirectLoc = ""

    # 更新用セッション値のクリア
    session[HtmlUtil::TEMPPASS] = ""
    session[HtmlUtil::TEMPNAME] = ""
    session[HtmlUtil::TEMPUID]  = ""

    uid = session[HtmlUtil::LOGINID]
    curuid = args[0]["curuid"][0]
    newuid = args[0]["uid"][0]
    curname = args[0]["curname"][0]
    newname = args[0]["name"][0]
    curpass = args[0]["curpass"][0]
    newpass = args[0]["newpass"][0]
    confpass = args[0]["confpass"][0]

    # 入力値等のValidation
    isErr = false
    updatable = false

    # uidとcuruidが一致しない場合、エラー(再ログイン後、タブ使用？)
    isErr = true unless uid == curuid

    # confpassとnewpassが一致しない場合、エラー
    isErr = true unless confpass == newpass

    # curuidとnewuidが一致する場合、更新対象外
    updateUid = curuid != newuid
    # curnameとnewnameが一致する場合、更新対象外
    updateName = curname != newname
    # curpassとnewpassが一致する場合、更新対象外
    updatePass = curpass != newpass

    updatable = (updateUid or updateName or updatePass)

    # 3種の項目のうち1つ以上更新対象がある場合、確認画面表示
    if isErr
      form,isRedirect,redirectLoc = index session,args
      form = "<p>入力エラー！入力を確認してください。</p>\n" + form
      return form,isRedirect,redirectLoc
    elsif !updatable
      form,isRedirect,redirectLoc = index session,args
      form = "<p>更新する情報はありません。</p>\n" + form
      return form,isRedirect,redirectLoc
    else
      actionUrl = HtmlUtil.createUrl HtmlUtil::PersonCtrlName,"update"
      cancelUrl = HtmlUtil.createUrl HtmlUtil::PersonCtrlName
      menuUrl = HtmlUtil.getMenuUrl

      session[HtmlUtil::TEMPPASS] = newpass if updatePass
      session[HtmlUtil::TEMPNAME] = newname if updateName
      session[HtmlUtil::TEMPUID]  = newuid  if updateUid

      form = <<-HTML
    <p><h2>ユーザ情報更新確認</h2></p>
    <form action="#{actionUrl}" method="post" accept-charset="UTF-8"
          autocomplete="off" name="personaldata">
      <input type="hidden" name="updateName" value="#{updateName}">
      <input type="hidden" name="updatePass" value="#{updatePass}">
      <input type="hidden" name="updateUid" value="#{updateUid}">
      <table>
        <tbody>
          <tr>
            <th>名前</th>
            <td>
              #{newname}
              <input type="hidden" name="newname" value="#{newname}">
            </td>
          </tr>
          <tr>
            <th>ログインID</th>
            <td>
              #{newuid}
              <input type="hidden" name="newuid" value="#{newuid}">
              <input type="hidden" name="curuid" value="#{curuid}">
            </td>
          </tr>
          <tr>
            <th>パスワード</th>
            <td>
              セキュリティ上、パスワードは非表示にしています。
              <ul>
                <li>現在のパスワード ********
                </li>
                <li>新しいパスワード ********
                </li>
                <li>新しいパスワード(確認) ********
                </li>
              </ul>
            </td>
          </tr>
        </tbody>
      </table>
      <input type="submit" value="更新">
      <a href="#{cancelUrl}">キャンセル(入力画面へ)</a>
    </form>
    <a href="#{menuUrl}">メニュー画面へ</a>
      HTML

      return form,isRedirect,redirectLoc
    end
  end

  def update session,args
    # 仕込んでおいたparameter取得
    updateName = args[0]["updateName"][0] == "true"
    updateUid = args[0]["updateUid"][0]   == "true"
    updatePass = args[0]["updatePass"][0] == "true"

    # セッションに保持していた変更値取得
    uppass = ""
    uppass = session[HtmlUtil::TEMPPASS] if updatePass
    upname = ""
    upname = session[HtmlUtil::TEMPNAME] if updateName
    upuid  = ""
    upuid  = session[HtmlUtil::TEMPUID]  if updateUid

    uid = session[HtmlUtil::LOGINID]

    # セッション値クリア
    session[HtmlUtil::TEMPPASS] = ""
    session[HtmlUtil::TEMPNAME] = ""
    session[HtmlUtil::TEMPUID]  = ""

    # 画面表示値取得
    curuid = args[0]["curuid"][0]
    newuid = args[0]["newuid"][0]
    newname = args[0]["newname"][0]

    # 入力値等のValidation
    updatable = false

    updateUid = (updateUid and (uid == curuid) and (newuid == upuid)) if updateUid
    updateName = (updateName and (newname == upname)) if updateName
    # updatePass = updatePass

    updatable = (updateUid or updateName or updatePass)

    if !updatable
      form,isRedirect,redirectLoc = index session,args
      form = "<p>システムエラー！管理者に連絡してください。</p>\n" + form
      return form,isRedirect,redirectLoc
    else
      if CgiUser.updateUser uid,upuid,upname,uppass
        # セッション情報更新
        session[HtmlUtil::LOGINID] = upuid if upuid != ""
        session[HtmlUtil::LOGINNAME] = upname if upname != ""

        isRedirect = true
        redirectLoc = HtmlUtil.createUrl HtmlUtil::PersonCtrlName
        return "",isRedirect,redirectLoc
      else
        form,isRedirect,redirectLoc = index session,args
        form = "<p>システムエラー！管理者に連絡してください。</p>\n" + form
        return form,isRedirect,redirectLoc
      end
    end
  end
end
