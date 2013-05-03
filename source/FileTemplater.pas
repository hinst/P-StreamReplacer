unit FileTemplater;

interface

uses
	Classes,
	
	StreamReplacer;

type

	TTemplateReplacement = class(TComponent)
		What: String;
		function Write(const aOutput: TStream): boolean; virtual;
	end;
	
	TTemplateStringReplacement = class(TTemplateReplacement)
	public
		Text: String;
		function Write(const aOutput: TStream): boolean; override;
	end;
	
	TTemplateFileReplacement = class(TTemplateReplacement)
	public
		FileName: String;
	end;

	TFileTemplater = class(TComponent)
	protected
		FReplacements: TList;
	public
		constructor Create(const aOwner: TComponent);
		procedure AddReplacement(const aReplacement: TTemplateReplacement);
	end;

implementation

constructor TFileTemplater.Create(const aOwner: TComponent);
begin
	inherited Create(aOwner);
end;

procedure TFileTemplater.AddReplacement(const aReplacement: TTemplateReplacement);
begin
	
end;

end.